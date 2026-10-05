import Testing
import Combine
import SwiftData
@testable import Storage

@MainActor
final class FilteredStorageTests {
    @Test
    func subscribeWithFilterEmitsMatchingStations() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let di = DIContainer.shared
        di.register(modelContainer: container)
        let store = di.dataStore

        var filter = StationFilter.empty
        filter.name = "test"
        var cancellable: AnyCancellable?
        var emitted: [StationEntityImpl] = []

        cancellable = store.stationsPublisher(filter: filter)
            .sink { result in
                emitted = Array(result.map { $0 as! StationEntityImpl })
            }

        let stations: [StationEntityImpl] = [
            .fixture(id: "s1", name: "test station"),
            .fixture(id: "s2", name: "another test"),
            .fixture(id: "s3", name: "unrelated"),
        ]

        try store.saveStations(stations)

        #expect(emitted.count == 2)
        #expect(emitted.allSatisfy { $0.name.localizedCaseInsensitiveContains("test") })

        let moreStation: StationEntityImpl = .fixture(id: "s4", name: "third test station")
        try store.saveStations([moreStation])

        #expect(emitted.count == 3)

        cancellable?.cancel()
    }

    @Test
    func saveTwiceDoesNotDuplicateStations() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let di = DIContainer.shared
        di.register(modelContainer: container)
        let store = di.dataStore

        let stations: [StationEntityImpl] = [
            .fixture(id: "s1", name: "Station One"),
            .fixture(id: "s2", name: "Station Two"),
            .fixture(id: "s3", name: "Station Three"),
        ]

        try store.saveStations(stations)
        try store.saveStations(stations)

        var cancellable: AnyCancellable?
        var count = 0
        cancellable = store.stationsPublisher(filter: .empty)
            .sink { result in
                count = result.count
            }

        #expect(count == 3)
        cancellable?.cancel()
    }

    // NOTE: removeDuplicates test not possible with [any StationEntity] existential
    // because existential types cannot conform to Equatable.
    // Will be addressed in Phase 5 when replacing AnyPublisher with AsyncSequence.
}
