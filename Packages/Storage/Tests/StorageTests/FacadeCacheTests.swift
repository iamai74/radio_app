import Testing
import Combine
@testable import Storage

/// The facade wraps each repository's publisher/sequence in extra Combine or
/// `StorageSequence` layers (`map` to existential DTOs). Those wrappers must
/// not sever the anchor that keeps a filter's cached results alive — the
/// weak registry relies on the subscriber's publisher chain capturing the
/// filter state (see `EntityStorage.filteredValues(filter:)`).
@MainActor
final class FacadeCacheTests {
    @Test
    func filterCacheEvictsWhenFacadePublisherSubscriberGoesAway() throws {
        let store = try Storage.DataStore.makeInMemoryStore()
        #expect(store.cachedFilterCount == 0)

        var cancellable: AnyCancellable? = store.stationsPublisher(filter: .empty).sink { _ in }
        #expect(store.cachedFilterCount == 1)

        cancellable?.cancel()
        cancellable = nil
        #expect(store.cachedFilterCount == 0, "facade map chain must not outlive the subscriber")
    }

    @Test
    func filterCacheEvictsWhenFacadeSequenceIteratorGoesAway() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        do {
            var iterator = store.stationsSequence(filter: .empty).makeAsyncIterator()
            _ = try await iterator.next()
            #expect(store.cachedFilterCount == 1)
        }

        #expect(store.cachedFilterCount == 0, "dropping the iterator must release the cache")
    }

    @Test
    func repeatedSubscribeCancelCyclesLeaveNoCachedFilters() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()
        try await store.saveStations([StationDTO.fixture()])

        for _ in 0..<25 {
            var cancellable: AnyCancellable? = store.stationsPublisher(filter: .empty).sink { _ in }
            var iterator = store.stationsSequence(filter: .empty).makeAsyncIterator()
            _ = try await iterator.next()
            cancellable?.cancel()
            cancellable = nil
        }

        #expect(store.cachedFilterCount == 0)
    }
}
