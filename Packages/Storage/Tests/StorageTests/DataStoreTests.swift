import Testing
@testable import Storage

@MainActor
final class DataStoreTests {
    func makeStore() async throws -> Storage.DataStore {
        let container = try Storage.StorageContainer.create(isInMemory: true)
        let di = Storage.DIContainer.shared
        di.register(modelContainer: container)
        return di.dataStore
    }

    @Test
    func saveFreshStationsWithSameIdsDoesNotThrow() async throws {
        let store = try await makeStore()

        let batch1: [StationEntityImpl] = [
            StationEntityImpl.fixture(id: "s1", name: "Station One"),
            StationEntityImpl.fixture(id: "s2", name: "Station Two"),
            StationEntityImpl.fixture(id: "s3", name: "Station Three")
        ]

        // First save should work
        try store.saveStations(batch1)

        // Second save with *new* instances (simulating re-import) — should not throw or duplicate
        let batch2: [StationEntityImpl] = [
            StationEntityImpl.fixture(id: "s1", name: "Station One Updated"),
            StationEntityImpl.fixture(id: "s2", name: "Station Two"),
            StationEntityImpl.fixture(id: "s3", name: "Station Three")
        ]

        try store.saveStations(batch2)
    }
}
