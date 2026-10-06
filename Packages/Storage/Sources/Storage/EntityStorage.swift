import Foundation
import SwiftData
import Combine

/// Owns one entity type's read/write pipeline: SQLite pushdown, in-memory
/// fallback, publication of results, and background writes.
///
/// All filter-specific behaviour arrives as a `FilterStrategy` value
/// (composition instead of the previous subclass hooks), so the pipeline is a
/// pure function that tests can drive without SwiftData.
///
/// Filter results are cached per filter in a registry that holds them
/// **weakly**: the publisher chain returned by `filteredPublisher` is what
/// keeps a filter's state alive, so dropping the last subscriber releases the
/// cached array and `reload()` stops recomputing it. There is no unbounded
/// growth for filters nobody looks at any more.
@MainActor
final class EntityStorage<Entity: PersistentModel & StorageModel & Hashable, Filter: Hashable> {
    let modelContext: ModelContext
    let failureSubject = PassthroughSubject<StorageError, Never>()

    private let strategy: FilterStrategy<Entity, Filter>
    private let writer: BackgroundModelWriter
    private let subject = CurrentValueSubject<[Entity], Never>([])
    private var filterStates: [Filter: WeakFilterState] = [:]

    /// One filter's published results. Held weakly by the registry; strongly
    /// by the publisher chain that created it (see `filteredValues(filter:)`).
    private final class FilterState {
        let filter: Filter
        let subject: CurrentValueSubject<[Entity], Never>

        init(filter: Filter) {
            self.filter = filter
            self.subject = CurrentValueSubject([])
        }
    }

    private struct WeakFilterState {
        weak var state: FilterState?
    }

    init(modelContext: ModelContext, strategy: FilterStrategy<Entity, Filter>) {
        self.modelContext = modelContext
        self.strategy = strategy
        self.writer = BackgroundModelWriter(container: modelContext.container)
    }

    // MARK: - Writing

    /// Upserts on a background context, then refreshes published results.
    func save(_ entities: [Entity]) async throws {
        do {
            try await writer.upsert(DetachedModels(entities))
        } catch {
            throw StorageError.saveFailed("\(Entity.self) upsert: \(error)")
        }
        reload()
    }

    /// Deletes every row on the background context, then clears published results.
    func deleteAll() async throws {
        do {
            try await writer.deleteAll(Entity.self)
        } catch {
            throw StorageError.saveFailed("\(Entity.self) deleteAll: \(error)")
        }
        subject.send([])
        pruneFilterStates()
        for reference in filterStates.values {
            reference.state?.subject.send([])
        }
    }

    // MARK: - Filtering

    /// Attempts predicate-based fetch at SQLite level; falls back to the
    /// in-memory pipeline when the strategy has no predicate for the filter.
    func fetchFiltered(_ filter: Filter) throws -> [Entity] {
        guard let predicate = strategy.predicate(filter) else {
            return strategy.filtered(filter, in: try modelContext.fetch(FetchDescriptor<Entity>()))
        }

        // SQLite applies offset/limit while fetching, so whenever results still
        // need post-processing the window has to be applied afterwards instead.
        let deferredWindow = strategy.requiresPostProcessing(filter)
        var results = try fetchWithPredicate(predicate, filter: filter, windowedInSQLite: !deferredWindow)
        if deferredWindow {
            strategy.postProcess(filter, &results)
            results = strategy.windowed(filter, results)
        }
        return results
    }

    /// The pure in-memory pipeline, exposed so parity tests can compare it
    /// against `fetchFiltered` on the same rows.
    func filtered(_ filter: Filter, in all: [Entity]) -> [Entity] {
        strategy.filtered(filter, in: all)
    }

    private func fetchWithPredicate(
        _ predicate: Predicate<Entity>,
        filter: Filter,
        windowedInSQLite: Bool
    ) throws -> [Entity] {
        var descriptor = FetchDescriptor<Entity>(
            predicate: predicate,
            sortBy: strategy.sortDescriptors(filter) ?? strategy.defaultSortDescriptors
        )

        // Only touch the window when the filter actually has one. Leaving
        // `fetchLimit`/`fetchOffset` untouched keeps "unlimited" as the SDK
        // default instead of relying on `0` meaning the same thing.
        if windowedInSQLite {
            if let offset = strategy.fetchOffset(filter) {
                descriptor.fetchOffset = offset
            }
            if let limit = strategy.fetchLimit(filter) {
                descriptor.fetchLimit = limit
            }
        }

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Publication

    private var publisher: AnyPublisher<[Entity], Never> {
        subject.eraseToAnyPublisher()
    }

    /// Async view of the unfiltered results.
    var sequence: StorageSequence<Entity> {
        StorageSequence(values: publisher, failures: failureSubject.eraseToAnyPublisher())
    }

    /// Publishes `filter`'s results. The filter is registered (and fetched)
    /// synchronously on first use, so a subscriber always receives the current
    /// value immediately instead of an empty array followed by a refetch.
    func filteredPublisher(filter: Filter) -> AnyPublisher<[Entity], Never> {
        filteredValues(filter: filter).eraseToAnyPublisher()
    }

    /// Async counterpart of `filteredPublisher(filter:)`, carrying
    /// `StorageError` instead of swallowing it.
    func filteredSequence(filter: Filter) -> StorageSequence<Entity> {
        StorageSequence(values: filteredValues(filter: filter), failures: failureSubject.eraseToAnyPublisher())
    }

    private func filteredValues(filter: Filter) -> AnyPublisher<[Entity], Never> {
        let state = state(for: filter)
        // The `handleEvents` closures capture `state`, and the subscription
        // keeps those closures for as long as the subscriber is attached, so
        // the publisher chain is what holds the registry entry alive. The
        // registry itself only holds it weakly: when the last subscriber
        // cancels the closures go away with the subscription, the state is
        // released, and the next `reload()` prunes the entry. Without this
        // anchor the entry dies right after subscription and `reload()` stops
        // republishing to it.
        return state.subject
            .handleEvents(
                receiveSubscription: { _ in _ = state },
                receiveCancel: { _ = state }
            )
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func state(for filter: Filter) -> FilterState {
        if let existing = filterStates[filter]?.state {
            return existing
        }
        let state = FilterState(filter: filter)
        filterStates[filter] = WeakFilterState(state: state)
        publish(filter, to: state)
        return state
    }

    /// Fetches `filter` and pushes the result.
    ///
    /// Failures are surfaced on `failureSubject` instead of being swallowed:
    /// the previous value stays in place, so subscribers see "nothing changed"
    /// and `failures` tells them why — never a silent empty array.
    private func publish(_ filter: Filter, to state: FilterState) {
        do {
            state.subject.send(try fetchFiltered(filter))
        } catch {
            failureSubject.send(.fetchFailed("\(Entity.self) filter: \(error)"))
        }
    }

    /// Refetches everything from the main context and republishes.
    ///
    /// Read failures are surfaced on `failureSubject` instead of being printed:
    /// a caller iterating the sequence should be able to react to them. They are
    /// not rethrown, because the write that triggered the reload already
    /// succeeded and throwing would misreport it as a save failure.
    func reload() {
        do {
            let descriptor = FetchDescriptor<Entity>(sortBy: strategy.defaultSortDescriptors)
            subject.send(try modelContext.fetch(descriptor))
        } catch {
            failureSubject.send(.fetchFailed("\(Entity.self) reload: \(error)"))
        }

        pruneFilterStates()
        for reference in filterStates.values {
            if let state = reference.state {
                publish(state.filter, to: state)
            }
        }
    }

    // MARK: - Filter registry

    /// Drops caches whose publishers were all released.
    private func pruneFilterStates() {
        filterStates = filterStates.filter { $0.value.state != nil }
    }

    /// Number of filters with live cached results. Diagnostic/test hook; it
    /// prunes first so a dropped publisher disappears from the count.
    var cachedFilterCount: Int {
        pruneFilterStates()
        return filterStates.count
    }
}
