import Foundation
import SwiftData
import Combine

/// Owns one entity type's read/write pipeline: SQLite pushdown, in-memory
/// fallback, publication of results, and background writes.
///
/// All filter-specific behaviour arrives as a `FilterStrategy` value
/// (composition instead of the previous subclass hooks), and the SQLite
/// half of every filter is resolved through a single `FetchPlan` the strategy
/// builds, so the pipeline is a pure function that tests can drive without
/// SwiftData.
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
            throw StorageError.saveFailed(details: "\(Entity.self) upsert: \(error)", underlying: error)
        }
        reload()
    }

    /// Deletes every row on the background context, then clears published results.
    func deleteAll() async throws {
        do {
            try await writer.deleteAll(Entity.self)
        } catch {
            throw StorageError.saveFailed(details: "\(Entity.self) deleteAll: \(error)", underlying: error)
        }
        subject.send([])
        pruneFilterStates()
        for reference in filterStates.values {
            reference.state?.subject.send([])
        }
    }

    // MARK: - Filtering

    /// Resolves the filter into a `FetchPlan` and runs the two-tier pipeline:
    /// SQLite fetch when the plan has a predicate, then — only when the plan
    /// says the window is deferred — post-processing and the in-memory window.
    func fetchFiltered(_ filter: Filter) throws -> [Entity] {
        let plan = strategy.plan(filter)
        guard let predicate = plan.predicate else {
            return strategy.filtered(filter, in: try modelContext.fetch(FetchDescriptor<Entity>()))
        }

        var results = try fetchWithPredicate(predicate, plan: plan)
        if !plan.windowInSQLite {
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

    private func fetchWithPredicate(_ predicate: Predicate<Entity>, plan: FetchPlan<Entity>) throws -> [Entity] {
        // Only touch the window when the plan carries one; by construction
        // that is exactly when SQLite may apply it (`windowInSQLite`).
        var descriptor = FetchDescriptor<Entity>(
            predicate: predicate,
            sortBy: plan.sortDescriptors
        )
        if let offset = plan.offset {
            descriptor.fetchOffset = offset
        }
        if let limit = plan.limit {
            descriptor.fetchLimit = limit
        }
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Publication

    private var publisher: AnyPublisher<[Entity], Never> {
        subject.eraseToAnyPublisher()
    }

    /// Publishes `filter`'s results. The filter is registered (and fetched)
    /// synchronously on first use, so a subscriber always receives the current
    /// value immediately instead of an empty array followed by a refetch.
    func filteredPublisher(filter: Filter) -> AnyPublisher<[Entity], Never> {
        filteredValues(filter: filter).eraseToAnyPublisher()
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
            failureSubject.send(.fetchFailed(details: "\(Entity.self) filter: \(error)", underlying: error))
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
            failureSubject.send(.fetchFailed(details: "\(Entity.self) reload: \(error)", underlying: error))
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
