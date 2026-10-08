import Foundation
import SwiftData
@preconcurrency import Combine

@MainActor
final class EntityStorage<Entity: PersistentModel & StorageModel & Hashable, Filter: Hashable> {
    let modelContext: ModelContext
    let failureSubject = PassthroughSubject<StorageError, Never>()

    private let strategy: FilterStrategy<Entity, Filter>
    private let subject = CurrentValueSubject<[Entity], Never>([])
    private var filterStates: [Filter: WeakFilterState] = [:]

    init(modelContext: ModelContext, strategy: FilterStrategy<Entity, Filter>) {
        self.modelContext = modelContext
        self.strategy = strategy
    }

    func save(_ entities: [Entity]) async throws {
        do {
            let deduplicated = Self.deduplicatedByKey(entities)
            for model in deduplicated {
                if let existing = try? modelContext.fetch(FetchDescriptor<Entity>(predicate: Entity.predicate(forKeys: [model.storageKey]))).first {
                    existing.applyUpdate(from: model)
                } else {
                    modelContext.insert(model)
                }
            }
            try modelContext.save()
        } catch {
            throw StorageError.saveFailed(details: "\(Entity.self) upsert: \(error)", underlying: error)
        }
        reload()
    }

    func deleteAll() async throws {
        do {
            try modelContext.delete(model: Entity.self)
            try modelContext.save()
        } catch {
            throw StorageError.saveFailed(details: "\(Entity.self) deleteAll: \(error)", underlying: error)
        }
        subject.send([])
        pruneFilterStates()
        for reference in filterStates.values {
            reference.state?.subject.send([])
        }
    }

    func fetchFiltered(_ filter: Filter) throws -> [Entity] {
        let plan = strategy.plan(filter)
        guard let predicate = plan.predicate else {
            return strategy.filtered(filter, in: try modelContext.fetch(FetchDescriptor<Entity>()))
        }

        var descriptor = FetchDescriptor<Entity>(predicate: predicate, sortBy: plan.sortDescriptors)
        if let offset = plan.offset { descriptor.fetchOffset = offset }
        if let limit = plan.limit { descriptor.fetchLimit = limit }

        var results = try modelContext.fetch(descriptor)
        if !plan.windowInSQLite {
            strategy.postProcess(filter, &results)
            results = strategy.windowed(filter, results)
        }
        return results
    }

    func filtered(_ filter: Filter, in all: [Entity]) -> [Entity] {
        strategy.filtered(filter, in: all)
    }

    func publisher(filter: Filter) -> AnyPublisher<[Entity], Never> {
        let state: FilterState
        if let existing = filterStates[filter]?.state {
            state = existing
        } else {
            state = FilterState(filter: filter)
            filterStates[filter] = WeakFilterState(state: state)
            publish(filter, to: state)
        }
        return state.subject
            .handleEvents(
                receiveSubscription: { _ in _ = state },
                receiveCancel: { _ = state }
            )
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func filteredPublisher(filter: Filter) -> AnyPublisher<[Entity], Never> {
        publisher(filter: filter)
    }

    func reload() {
        do {
            let descriptor = FetchDescriptor<Entity>(sortBy: strategy.defaultSortDescriptors)
            subject.send(try modelContext.fetch(descriptor))
        } catch {
            failureSubject.send(.fetchFailed(details: "\(Entity.self) reload: \(error)", underlying: error))
        }

        pruneFilterStates()
        for reference in filterStates.values {
            if let state = reference.state {
                publish(state.filter, to: state)
            }
        }
    }

    private func publish(_ filter: Filter, to state: FilterState) {
        do {
            state.subject.send(try fetchFiltered(filter))
        } catch {
            failureSubject.send(.fetchFailed(details: "\(Entity.self) filter: \(error)", underlying: error))
        }
    }

    private final class FilterState: @unchecked Sendable {
        let filter: Filter
        let subject: CurrentValueSubject<[Entity], Never>

        init(filter: Filter) {
            self.filter = filter
            self.subject = CurrentValueSubject([])
        }
    }

    private struct WeakFilterState: Sendable {
        weak var state: FilterState?
    }

    private func pruneFilterStates() {
        filterStates = filterStates.filter { $0.value.state != nil }
    }

    private static func deduplicatedByKey(_ models: [Entity]) -> [Entity] {
        var seenKeys = Set<String>()
        var keptReversed: [Entity] = []
        keptReversed.reserveCapacity(models.count)
        for model in models.reversed() where seenKeys.insert(model.storageKey).inserted {
            keptReversed.append(model)
        }
        return keptReversed.reversed()
    }

    var cachedFilterCount: Int {
        pruneFilterStates()
        return filterStates.count
    }
}
