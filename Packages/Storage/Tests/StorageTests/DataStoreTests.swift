import Testing
import Combine
@testable import Storage

@MainActor
final class DataStoreTests {
    @Test
    func saveFreshStationsWithSameIdsDoesNotThrow() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        let batch1: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "Station One"),
            StationDTO.fixture(id: "s2", name: "Station Two"),
            StationDTO.fixture(id: "s3", name: "Station Three")
        ]

        // First save should work
        try await store.saveStations(batch1)

        // Second save with *new* instances (simulating re-import) — should not throw or duplicate
        let batch2: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "Station One Updated"),
            StationDTO.fixture(id: "s2", name: "Station Two"),
            StationDTO.fixture(id: "s3", name: "Station Three")
        ]

        try await store.saveStations(batch2)
    }

    /// Writes land on a background context, so the main context has to pick the
    /// updated rows up — including the fields that changed on re-import.
    @Test
    func reimportUpdatesExistingRowsOnBackgroundWrite() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveStations([StationDTO.fixture(id: "s1", name: "Before", votes: 1)])
        try await store.saveStations([StationDTO.fixture(id: "s1", name: "After", votes: 42)])

        var emitted: [any StationEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.stationsPublisher(filter: .empty)
            .sink { emitted = $0 }

        #expect(emitted.count == 1)
        let station = try #require(emitted.first)
        #expect(station.name == "After")
        #expect(station.votes == 42)

        cancellable?.cancel()
    }

    @Test
    func deleteAllStationsClearsStore() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveStations([
            StationDTO.fixture(id: "s1", name: "One"),
            StationDTO.fixture(id: "s2", name: "Two")
        ])

        try await store.deleteAllStations()

        var emitted: [any StationEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.stationsPublisher(filter: .empty)
            .sink { emitted = $0 }

        #expect(emitted.isEmpty)

        cancellable?.cancel()
    }

    @Test
    func bulkImportRoundTripsThroughBackgroundWriter() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        let batch = (1...2_000).map {
            StationDTO.fixture(id: "s\($0)", name: "Station \($0)")
        }
        try await store.saveStations(batch)

        var emitted: [any StationEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.stationsPublisher(filter: .empty)
            .sink { emitted = $0 }

        #expect(emitted.count == 2_000)
        #expect(emitted.first?.id == "s1")

        try await store.deleteAllStations()

        cancellable?.cancel()
    }

    @Test
    func concurrentSavesAreSerialisedThroughTheBackgroundWriter() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0 ..< 8 {
                group.addTask {
                    try await store.saveTags([
                        TagDTO.fixture(name: "tag-\(index)", stationCount: index)
                    ])
                }
            }
            try await group.waitForAll()
        }

        let names = try store.rowCount(TagEntityImpl.self)
        #expect(names == 8)
    }
}
