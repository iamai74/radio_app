import Testing
import Combine
import SwiftData
@testable import Storage

@MainActor
final class FilteredStorageTests {
    @Test
    func subscribeWithFilterEmitsMatchingStations() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let store = Storage.DataStore(modelContainer: container)

        var filter = StationFilter.empty
        filter.name = "test"
        var cancellable: AnyCancellable?
        var emitted: [any StationEntity] = []

        cancellable = store.stationsPublisher(filter: filter)
            .sink { emitted = $0 }

        let stations: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "test station"),
            StationDTO.fixture(id: "s2", name: "another test"),
            StationDTO.fixture(id: "s3", name: "unrelated")
        ]

        try await store.saveStations(stations)

        #expect(emitted.count == 2)
        #expect(emitted.allSatisfy { $0.name.localizedCaseInsensitiveContains("test") })

        let moreStation = StationDTO.fixture(id: "s4", name: "third test station")
        try await store.saveStations([moreStation])

        #expect(emitted.count == 3)

        cancellable?.cancel()
    }

    @Test
    func saveTwiceDoesNotDuplicateStations() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let store = Storage.DataStore(modelContainer: container)

        let stations: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "Station One"),
            StationDTO.fixture(id: "s2", name: "Station Two"),
            StationDTO.fixture(id: "s3", name: "Station Three")
        ]

        try await store.saveStations(stations)
        try await store.saveStations(stations)

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

    @Test
    func predicateFilterByCountryWorks() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let store = Storage.DataStore(modelContainer: container)

        var filter = StationFilter.empty
        filter.country = "US"
        var cancellable: AnyCancellable?
        var emitted: [any StationEntity] = []

        cancellable = store.stationsPublisher(filter: filter)
            .sink { emitted = $0 }

        let stations: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "US Station", country: "US"),
            StationDTO.fixture(id: "s2", name: "UK Station", country: "GB"),
            StationDTO.fixture(id: "s3", name: "Another US", country: "US")
        ]

        try await store.saveStations(stations)

        #expect(emitted.count == 2)
        #expect(emitted.allSatisfy { $0.country == "US" })

        cancellable?.cancel()
    }

    @Test
    func predicateFilterByLanguageAndCountryWorks() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let store = Storage.DataStore(modelContainer: container)

        var filter = StationFilter.empty
        filter.country = "US"
        filter.language = "English"
        var cancellable: AnyCancellable?
        var emitted: [any StationEntity] = []

        cancellable = store.stationsPublisher(filter: filter)
            .sink { emitted = $0 }

        let stations: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "US English", country: "US", language: "English"),
            StationDTO.fixture(id: "s2", name: "US Spanish", country: "US", language: "Spanish"),
            StationDTO.fixture(id: "s3", name: "UK English", country: "GB", language: "English"),
            StationDTO.fixture(id: "s4", name: "US English 2", country: "US", language: "English")
        ]

        try await store.saveStations(stations)

        #expect(emitted.count == 2)

        cancellable?.cancel()
    }

    @Test
    func predicateFilterWithLimitAndOffsetWorks() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let store = Storage.DataStore(modelContainer: container)

        var filter = StationFilter.empty
        filter.limit = 2
        filter.offset = 1
        var cancellable: AnyCancellable?
        var emitted: [any StationEntity] = []

        cancellable = store.stationsPublisher(filter: filter)
            .sink { emitted = $0 }

        let stations: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "First"),
            StationDTO.fixture(id: "s2", name: "Second"),
            StationDTO.fixture(id: "s3", name: "Third"),
            StationDTO.fixture(id: "s4", name: "Fourth")
        ]

        try await store.saveStations(stations)

        #expect(emitted.count == 2)

        cancellable?.cancel()
    }

    @Test
    func tagFilterFallsBackToInMemory() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let store = Storage.DataStore(modelContainer: container)

        var filter = StationFilter.empty
        filter.tag = "jazz"
        var cancellable: AnyCancellable?
        var emitted: [any StationEntity] = []

        cancellable = store.stationsPublisher(filter: filter)
            .sink { emitted = $0 }

        let stations: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "Jazz Station", tags: ["jazz", "live"]),
            StationDTO.fixture(id: "s2", name: "Rock Station", tags: ["rock", "live"]),
            StationDTO.fixture(id: "s3", name: "Smooth Jazz", tags: ["jazz", "chill"])
        ]

        try await store.saveStations(stations)

        #expect(emitted.count == 2)
        #expect(emitted.allSatisfy { station in
            station.tags?.contains(where: { $0.localizedCaseInsensitiveContains("jazz") }) ?? false
        })

        cancellable?.cancel()
    }

    @Test
    func lastCheckOkSortFallsBackToInMemory() async throws {
        let container = try StorageContainer.create(isInMemory: true)
        let store = Storage.DataStore(modelContainer: container)

        var filter = StationFilter.empty
        filter.orderBy = .lastCheckOk
        var cancellable: AnyCancellable?
        var emitted: [any StationEntity] = []

        cancellable = store.stationsPublisher(filter: filter)
            .sink { emitted = $0 }

        let stations: [StationDTO] = [
            StationDTO.fixture(id: "s1", name: "Bad", lastCheckOk: false),
            StationDTO.fixture(id: "s2", name: "Good", lastCheckOk: true),
            StationDTO.fixture(id: "s3", name: "Good 2", lastCheckOk: true)
        ]

        try await store.saveStations(stations)

        #expect(emitted.count == 3)
        #expect(emitted.first?.lastCheckOk == true)

        cancellable?.cancel()
    }
}
