import Testing
import Combine
@testable import Storage

@MainActor
final class FacetStorageTests {
    @Test
    func savesAndPublishesCountries() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveCountries([
            CountryEntityImpl.fixture(name: "United States", iso31661: "US", stationCount: 100),
            CountryEntityImpl.fixture(name: "Germany", iso31661: "DE", stationCount: 50)
        ])

        var emitted: [any CountryEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.countriesPublisher(filter: .empty)
            .sink { emitted = $0 }

        #expect(emitted.count == 2)
        #expect(emitted.contains { $0.iso31661 == "DE" })

        cancellable?.cancel()
    }

    @Test
    func filtersFacetsByNameAndMinStationCount() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveTags([
            TagEntityImpl.fixture(name: "jazz", stationCount: 30),
            TagEntityImpl.fixture(name: "jazz fusion", stationCount: 5),
            TagEntityImpl.fixture(name: "rock", stationCount: 90)
        ])

        var filter = FacetFilter.empty
        filter.name = "jazz"
        filter.minStationCount = 10

        var emitted: [any TagEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.tagsPublisher(filter: filter)
            .sink { emitted = $0 }

        #expect(emitted.count == 1)
        #expect(emitted.first?.name == "jazz")

        cancellable?.cancel()
    }

    @Test
    func ordersFacetsByStationCount() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveCodecs([
            CodecEntityImpl.fixture(name: "MP3", stationCount: 300),
            CodecEntityImpl.fixture(name: "AAC", stationCount: 10),
            CodecEntityImpl.fixture(name: "Ogg", stationCount: 120)
        ])

        var filter = FacetFilter.empty
        filter.orderBy = .stationCount

        var emitted: [any CodecEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.codecsPublisher(filter: filter)
            .sink { emitted = $0 }

        #expect(emitted.map(\.name) == ["MP3", "Ogg", "AAC"])

        cancellable?.cancel()
    }

    @Test
    func reverseOrderIsApplied() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveLanguages([
            LanguageEntityImpl.fixture(name: "English", stationCount: 200),
            LanguageEntityImpl.fixture(name: "Spanish", stationCount: 50)
        ])

        var filter = FacetFilter.empty
        filter.orderBy = .stationCount
        filter.reverse = true

        var emitted: [any LanguageEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.languagesPublisher(filter: filter)
            .sink { emitted = $0 }

        #expect(emitted.map(\.name) == ["Spanish", "English"])

        cancellable?.cancel()
    }

    @Test
    func reimportUpdatesFacetsInPlace() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveTags([TagEntityImpl.fixture(name: "jazz", stationCount: 30)])
        try await store.saveTags([TagEntityImpl.fixture(name: "jazz", stationCount: 31)])

        var emitted: [any TagEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.tagsPublisher(filter: .empty)
            .sink { emitted = $0 }

        #expect(emitted.count == 1)
        #expect(emitted.first?.stationCount == 31)

        cancellable?.cancel()
    }

    @Test
    func deleteAllTagsClearsStore() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveTags([TagEntityImpl.fixture(name: "jazz")])
        try await store.deleteAllTags()

        var emitted: [any TagEntity] = []
        var cancellable: AnyCancellable?
        cancellable = store.tagsPublisher(filter: .empty)
            .sink { emitted = $0 }

        #expect(emitted.isEmpty)

        cancellable?.cancel()
    }
}
