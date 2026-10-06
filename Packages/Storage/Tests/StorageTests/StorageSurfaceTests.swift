import Testing
import Combine
import SwiftData
@testable import Storage

/// Behaviour of the surface the filtering pipeline exposes: how the registry
/// keeps filter caches alive, and how read failures reach consumers.
@MainActor
final class StorageSurfaceTests {
    /// The registry holds filter caches weakly; the subscriber's own chain is
    /// what keeps one alive. Dropping the subscriber must release it, or
    /// `reload()` would keep recomputing results for filters nobody reads.
    @Test
    func filterRegistryEvictsWhenSubscriberGoesAway() throws {
        let container = try StorageContainer.create(isInMemory: true)
        let storage = EntityStorage<StationEntityImpl, StationFilter>(
            modelContext: container.mainContext,
            strategy: .station
        )
        #expect(storage.cachedFilterCount == 0)

        var cancellable: AnyCancellable? = storage.filteredPublisher(filter: .empty).sink { _ in }
        #expect(storage.cachedFilterCount == 1)

        // A second subscriber to the same filter shares the cached state.
        let second = storage.filteredPublisher(filter: .empty).sink { _ in }
        #expect(storage.cachedFilterCount == 1)

        cancellable?.cancel()
        cancellable = nil
        #expect(storage.cachedFilterCount == 1, "the second subscriber still needs the cache")

        second.cancel()
        #expect(storage.cachedFilterCount == 0, "no subscribers left, cache must evict")
    }

    /// A read failure reaches async consumers as a thrown `StorageError` after
    /// they have received the current value — writes still report by throwing,
    /// reads by failing the stream.
    @Test
    func readFailuresSurfaceOnTheAsyncSequence() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let storage = EntityStorage<StationEntityImpl, StationFilter>(
            modelContext: container.mainContext,
            strategy: .station
        )

        var iterator = storage.filteredSequence(filter: .empty).makeAsyncIterator()
        #expect(try await iterator.next() == [], "replays the current (empty) value first")

        storage.failureSubject.send(.fetchFailed("simulated"))

        do {
            _ = try await iterator.next()
            Issue.record("expected the failure to surface as a thrown StorageError")
        } catch let error as StorageError {
            #expect(error == .fetchFailed("simulated"))
        }
    }
}
