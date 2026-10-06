import Testing
@testable import Storage

/// The concrete `*Record` DTOs are the package's default value types for the
/// entity protocols: they must round-trip through save → background upsert →
/// publish without any custom conformer in the caller.
@MainActor
final class RecordDTOTests {
    @Test
    func stationRecordRoundTripsThroughSaveAndPublish() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()
        let record = StationRecord(
            id: "record-1",
            name: "Recorded Station",
            url: "https://example.com/stream",
            country: "US",
            tags: ["jazz", "live"],
            language: "English",
            votes: 7,
            bitrate: 192,
            lastCheckOk: true,
            changeCounter: 3
        )

        try await store.saveStations([record])

        var iterator = store.stationsSequence(filter: .empty).makeAsyncIterator()
        let stations = try await iterator.next()

        #expect(stations?.count == 1)
        #expect(stations?.first?.id == "record-1")
        #expect(stations?.first?.votes == 7)
        #expect(stations?.first?.tags == ["jazz", "live"])
    }

    @Test
    func stationRecordReimportUpdatesInPlace() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()
        try await store.saveStations([
            StationRecord(id: "r1", name: "First", url: "https://a", country: "US", votes: 1)
        ])
        try await store.saveStations([
            StationRecord(id: "r1", name: "First", url: "https://a", country: "US", votes: 2)
        ])

        var iterator = store.stationsSequence(filter: .empty).makeAsyncIterator()
        let stations = try await iterator.next()

        #expect(stations?.count == 1)
        #expect(stations?.first?.votes == 2)
    }

    @Test
    func facetRecordsRoundTripThroughSaveAndPublish() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()

        try await store.saveCountries([CountryRecord(name: "United States", iso31661: "US", stationCount: 100)])
        try await store.saveTags([TagRecord(name: "jazz", stationCount: 30)])
        try await store.saveLanguages([LanguageRecord(name: "English", stationCount: 200)])
        try await store.saveCodecs([CodecRecord(name: "MP3", stationCount: 300)])

        var countries = store.countriesSequence(filter: .empty).makeAsyncIterator()
        #expect(try await countries.next()?.map(\.iso31661) == ["US"])

        var tags = store.tagsSequence(filter: .empty).makeAsyncIterator()
        #expect(try await tags.next()?.map(\.name) == ["jazz"])

        var languages = store.languagesSequence(filter: .empty).makeAsyncIterator()
        #expect(try await languages.next()?.map(\.stationCount) == [200])

        var codecs = store.codecsSequence(filter: .empty).makeAsyncIterator()
        #expect(try await codecs.next()?.map(\.name) == ["MP3"])
    }

    @Test
    func recordsSurviveAFilteredPublisherSubscription() async throws {
        let store = try Storage.DataStore.makeInMemoryStore()
        try await store.saveStations([
            StationRecord(id: "r1", name: "Jazz One", url: "https://a", country: "US", tags: ["jazz"]),
            StationRecord(id: "r2", name: "Rock One", url: "https://b", country: "US", tags: ["rock"])
        ])

        var filter = StationFilter.empty
        filter.tag = "jazz"

        var emittedNames: [String] = []
        let cancellable = store.stationsPublisher(filter: filter)
            .sink { stations in emittedNames = stations.map(\.name) }

        #expect(emittedNames == ["Jazz One"])
        cancellable.cancel()
    }
}
