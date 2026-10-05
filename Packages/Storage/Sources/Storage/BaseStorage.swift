import Foundation
import SwiftData
import Combine

/// Filtering pipeline applied on the main actor.
///
/// Filtering runs in two tiers:
/// 1. `predicate(for:)` / `sortDescriptors(from:)` / `fetchOffset(from:)` /
///    `fetchLimit(from:)` push as much of the filter as possible into SQLite.
/// 2. Everything SQLite cannot express is applied in memory through the pure
///    `filtered(_:in:)` pipeline: `matching` → `ordered` → `windowed`.
///
/// Each hook is a pure function of its input, so subclasses cannot silently
/// mutate a caller's array and the pipeline order is fixed in one place.
@MainActor
class BaseStorage<Entity: PersistentModel & StorageUpsertKey & Hashable, Filter: Hashable>: AnyObject {
    let modelContext: ModelContext
    let subject: CurrentValueSubject<[Entity], Never>
    let filteredSubjects: CurrentValueSubject<[Filter: [Entity]], Never>
    let failureSubject = PassthroughSubject<StorageError, Never>()
    private let sortKeyPath: KeyPath<Entity, String>
    private let writer: BackgroundModelWriter

    var publisher: AnyPublisher<[Entity], Never> {
        subject.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, sortKeyPath: KeyPath<Entity, String>) {
        self.modelContext = modelContext
        self.writer = BackgroundModelWriter(container: modelContext.container)
        self.subject = CurrentValueSubject([])
        self.filteredSubjects = CurrentValueSubject([:])
        self.sortKeyPath = sortKeyPath
    }

    /// Upserts on a background context, then refreshes published results.
    func save(_ entities: [Entity]) async throws {
        do {
            try await writer.upsert(DetachedModels(entities), key: { $0.storageKey })
        } catch {
            throw StorageError.saveFailed("\(Entity.self) upsert: \(error)")
        }
        reload()
    }

    // MARK: - SQLite Pushdown Hooks

    /// Returns a SwiftData predicate for the filter when SQLite-level filtering is possible.
    /// Returns `nil` to fall back to the in-memory pipeline.
    func predicate(for filter: Filter) -> Predicate<Entity>? { nil }

    /// Returns sort descriptors for the filter when SQLite-level sorting is possible.
    /// Returns `nil` to use the default `sortKeyPath` sort.
    func sortDescriptors(from filter: Filter) -> [SortDescriptor<Entity>]? { nil }

    /// Returns fetch offset for the filter (e.g., pagination offset).
    func fetchOffset(from filter: Filter) -> Int? { nil }

    /// Returns fetch limit for the filter (e.g., max rows to return).
    func fetchLimit(from filter: Filter) -> Int? { nil }

    /// Whether `applyPostFilter` has work to do for this filter.
    func needsPostFilter(_ filter: Filter) -> Bool { false }

    /// Post-processing for results of a predicate fetch that SQLite cannot express.
    func applyPostFilter(_ filter: Filter, to results: inout [Entity]) {}

    // MARK: - In-Memory Pipeline

    /// Pure in-memory fallback: filter, order, then paginate.
    func filtered(_ filter: Filter, in all: [Entity]) -> [Entity] {
        windowed(ordered(matching(filter, in: all), by: filter), by: filter)
    }

    /// Keeps only the rows the filter selects. Default: keep everything.
    func matching(_ filter: Filter, in all: [Entity]) -> [Entity] { all }

    /// Single per-entity ordering source of truth for the in-memory path.
    /// Default: ascending by the storage's default sort key.
    func ordered(_ entities: [Entity], by filter: Filter) -> [Entity] {
        entities.sorted { $0[keyPath: sortKeyPath].localizedCompare($1[keyPath: sortKeyPath]) == .orderedAscending }
    }

    /// Applies offset/limit in memory. Default: keep everything.
    func windowed(_ entities: [Entity], by filter: Filter) -> [Entity] { entities }

    // MARK: - Filtered Fetching

    /// Attempts predicate-based fetch at SQLite level; falls back to the in-memory pipeline.
    func fetchFiltered(_ filter: Filter) throws -> [Entity] {
        guard let predicate = predicate(for: filter) else {
            return filtered(filter, in: try modelContext.fetch(FetchDescriptor<Entity>()))
        }

        // SQLite applies offset/limit while fetching, so whenever results still need
        // post-filtering the window has to be applied afterwards instead.
        let deferredWindow = needsPostFilter(filter)
        var results = try fetchWithPredicate(predicate, filter: filter, windowedInSQLite: !deferredWindow)
        if deferredWindow {
            applyPostFilter(filter, to: &results)
            results = windowed(results, by: filter)
        }
        return results
    }

    private func fetchWithPredicate(
        _ predicate: Predicate<Entity>,
        filter: Filter,
        windowedInSQLite: Bool
    ) throws -> [Entity] {
        let sorts = sortDescriptors(from: filter) ?? [SortDescriptor(sortKeyPath)]

        var descriptor = FetchDescriptor<Entity>(
            predicate: predicate,
            sortBy: sorts
        )

        // Only touch the window when the filter actually has one. Leaving
        // `fetchLimit`/`fetchOffset` untouched keeps "unlimited" as the SDK
        // default instead of relying on `0` meaning the same thing.
        if windowedInSQLite {
            if let offset = fetchOffset(from: filter) {
                descriptor.fetchOffset = offset
            }
            if let limit = fetchLimit(from: filter) {
                descriptor.fetchLimit = limit
            }
        }

        return try modelContext.fetch(descriptor)
    }

    func registerFilter(_ filter: Filter) {
        var current = filteredSubjects.value
        if current[filter] == nil {
            let filtered = (try? fetchFiltered(filter)) ?? []
            current[filter] = filtered
            filteredSubjects.send(current)
        }
    }

    /// Registers `filter` on first subscribe, then publishes its results.
    ///
    /// `removeDuplicates` works here because `[Entity]` is `Equatable` while
    /// `Entity == *EntityImpl`. Every publisher funnels through this method, so
    /// subscribers of the existential views in `DataStore` no longer see
    /// duplicate emissions.
    func filteredPublisher(filter: Filter) -> AnyPublisher<[Entity], Never> {
        filteredValues(filter: filter).eraseToAnyPublisher()
    }

    /// Async counterpart of `filteredPublisher(filter:)`, carrying `StorageError`
    /// instead of swallowing it.
    func filteredSequence(filter: Filter) -> StorageSequence<Entity> {
        registerFilter(filter)
        return StorageSequence(
            values: filteredValues(filter: filter),
            failures: failureSubject.eraseToAnyPublisher()
        )
    }

    /// Async view of the unfiltered results.
    var sequence: StorageSequence<Entity> {
        StorageSequence(
            values: subject.eraseToAnyPublisher(),
            failures: failureSubject.eraseToAnyPublisher()
        )
    }

    private func filteredValues(filter: Filter) -> AnyPublisher<[Entity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Refetches everything from the main context and republishes.
    ///
    /// Read failures are surfaced on `failureSubject` instead of being printed:
    /// a caller iterating the sequence should be able to react to them. They are
    /// not rethrown, because the write that triggered the reload already
    /// succeeded and throwing would misreport it as a save failure.
    func reload() {
        let descriptor = FetchDescriptor<Entity>(sortBy: [SortDescriptor(sortKeyPath)])

        do {
            let results = try modelContext.fetch(descriptor)
            subject.send(results)
        } catch {
            failureSubject.send(.fetchFailed("\(Entity.self) reload: \(error)"))
        }

        do {
            var current = filteredSubjects.value
            for filter in current.keys {
                current[filter] = try fetchFiltered(filter)
            }
            filteredSubjects.send(current)
        } catch {
            failureSubject.send(.fetchFailed("\(Entity.self) filtered reload: \(error)"))
        }
    }

    /// Deletes every row on the background context, then clears published results.
    func deleteAll() async throws {
        do {
            try await writer.deleteAll(Entity.self)
        } catch {
            throw StorageError.saveFailed("\(Entity.self) deleteAll: \(error)")
        }
        subject.send([])
        filteredSubjects.send([:])
    }
}
