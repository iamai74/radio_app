import Foundation
import SwiftData
import Combine

@MainActor
class BaseStorage<Entity: PersistentModel & StorageUpsertKey & Hashable, Filter: Hashable>: AnyObject {
    let modelContext: ModelContext
    let subject: CurrentValueSubject<[Entity], Never>
    let filteredSubjects: CurrentValueSubject<[Filter: [Entity]], Never>
    private let sortKeyPath: KeyPath<Entity, String>

    var publisher: AnyPublisher<[Entity], Never> {
        subject.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, sortKeyPath: KeyPath<Entity, String>, initial: [Entity] = []) {
        self.modelContext = modelContext
        self.subject = CurrentValueSubject(initial)
        self.filteredSubjects = CurrentValueSubject([:])
        self.sortKeyPath = sortKeyPath
    }

    func save(_ entities: [Entity]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<Entity>())
        let existingByStorageKey = Dictionary(
            uniqueKeysWithValues: existing.map { ($0.storageKey, $0) }
        )

        let savedKeys: Set<String> = Set(entities.map { $0.storageKey })

        for entity in entities {
            if let existingEntity = existingByStorageKey[entity.storageKey] {
                modelContext.delete(existingEntity)
            }
            modelContext.insert(entity)
        }

        try modelContext.save()
        targetedReload(changedKeys: savedKeys)
    }

    /// Returns a SwiftData predicate for the filter when SQLite-level filtering is possible.
    /// Returns `nil` to fall back to in-memory filtering via `applyFilter`.
    func predicate(for filter: Filter) -> Predicate<Entity>? { nil }

    /// Returns sort descriptors for the filter when SQLite-level sorting is possible.
    /// Returns `nil` to use the default `sortKeyPath` sort.
    func sortDescriptors(from filter: Filter) -> [SortDescriptor<Entity>]? { nil }

    /// Returns fetch offset for the filter (e.g., pagination offset).
    func fetchOffset(from filter: Filter) -> Int? { nil }

    /// Returns fetch limit for the filter (e.g., max rows to return).
    func fetchLimit(from filter: Filter) -> Int? { nil }

    // MARK: - In-Memory Filtering (fallback)

    func applyFilter(_ filter: Filter, to results: inout [Entity]) throws {}

    // MARK: - Filtered Fetching

    /// Attempts predicate-based fetch at SQLite level; falls back to in-memory filtering.
    func fetchFiltered(_ filter: Filter) throws -> [Entity] {
        if let predicate = predicate(for: filter) {
            var results = try fetchWithPredicate(predicate, filter: filter)
            applyPostFilter(filter, to: &results)
            return results
        }

        var filtered = try modelContext.fetch(FetchDescriptor<Entity>())
        try applyFilter(filter, to: &filtered)
        return filtered
    }

    private func fetchWithPredicate(_ predicate: Predicate<Entity>, filter: Filter) throws -> [Entity] {
        let sorts = sortDescriptors(from: filter) ?? [SortDescriptor(sortKeyPath)]

        var descriptor = FetchDescriptor<Entity>(
            predicate: predicate,
            sortBy: sorts
        )

        if let offset = fetchOffset(from: filter) {
            descriptor.fetchOffset = offset
        }

        if let limit = fetchLimit(from: filter) {
            descriptor.fetchLimit = limit
        }

        return try modelContext.fetch(descriptor)
    }

    /// Called after a predicate-based fetch to apply post-processing that SQLite
    /// cannot express (e.g. tag array filtering, complex sort orders).
    func applyPostFilter(_ filter: Filter, to results: inout [Entity]) {}

    func registerFilter(_ filter: Filter) {
        var current = filteredSubjects.value
        if current[filter] == nil {
            let filtered = (try? fetchFiltered(filter)) ?? []
            current[filter] = filtered
            filteredSubjects.send(current)
        }
    }

    // NOTE: `removeDuplicates` operates on `[Entity]`, which requires `Equatable`
    // conformance. When this publisher is used via existential boxing (e.g.
    // `[any StationEntity]`), the resulting type cannot conform to `Equatable`,
    // so `removeDuplicates` becomes a no-op. This limitation is documented in
    // `FilteredStorageTests.swift` and will be addressed in Phase 5 when the
    // publisher surface is replaced with `AsyncSequence` and typed return types.
    func filteredPublisher(filter: Filter) -> AnyPublisher<[Entity], Never> {
        filteredSubjects
            .map { $0[filter] ?? [] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func targetedReload(changedKeys: Set<String>) {
        let descriptor = FetchDescriptor<Entity>(sortBy: [SortDescriptor(sortKeyPath)])

        do {
            let results = try modelContext.fetch(descriptor)
            subject.send(results)
        } catch {
            print("[Storage] reload: fetch failed for \(Entity.self): \(error)")
        }

        do {
            var current = filteredSubjects.value
            for filter in current.keys {
                current[filter] = try fetchFiltered(filter)
            }
            filteredSubjects.send(current)
        } catch {
            print("[Storage] reload: filtered fetch/apply failed: \(error)")
        }
    }

    func reload() {
        let descriptor = FetchDescriptor<Entity>(sortBy: [SortDescriptor(sortKeyPath)])

        do {
            let results = try modelContext.fetch(descriptor)
            subject.send(results)
        } catch {
            print("[Storage] reload: fetch failed for \(Entity.self): \(error)")
        }

        do {
            var current = filteredSubjects.value
            for filter in current.keys {
                current[filter] = try fetchFiltered(filter)
            }
            filteredSubjects.send(current)
        } catch {
            print("[Storage] reload: filtered fetch/apply failed: \(error)")
        }
    }

    func saveBackground(_ entities: [Entity]) async {
        let container = modelContext.container

        let task = Task.detached(priority: .utility) { [weak self, entities, container] in
            let bgContext = ModelContext(container)

            let existing = try bgContext.fetch(FetchDescriptor<Entity>())
            let existingByStorageKey = Dictionary(
                uniqueKeysWithValues: existing.map { ($0.storageKey, $0) }
            )

            for entity in entities {
                if let existingEntity = existingByStorageKey[entity.storageKey] {
                    bgContext.delete(existingEntity)
                }
                bgContext.insert(entity)
            }

            try bgContext.save()

            await MainActor.run {
                self?.reload()
            }
        }

        do {
            _ = try await task.value
        } catch {
            print("[Storage] saveBackground: background save failed for \(Entity.self): \(error)")
        }
    }

    func deleteAll() throws {
        try modelContext.delete(model: Entity.self)
        try modelContext.save()
        subject.send([])
        filteredSubjects.send([:])
    }
}
