import Testing
import SwiftData
@testable import Storage

/// `fetchFiltered` (SQLite pushdown) and `filtered(_:in:)` (pure in-memory
/// pipeline) must select, order and window identically — the predicate and the
/// matching closure are written separately, so only these tests keep them
/// honest.
///
/// Fixture rules make the comparison meaningful instead of tie-luck: every sort
/// column is unique (no tie-breaking can diverge), insertion order equals name
/// order (an unsorted fetch and `SortDescriptor(\.name)` then agree), and names
/// are ASCII (BINARY collation matches Swift `<`).
@MainActor
final class FilterParityTests {
    @Test
    func stationFiltersMatchBetweenSQLiteAndMemory() throws {
        let container = try StorageContainer.create(isInMemory: true)
        let context = container.mainContext
        for station in Self.stations {
            context.insert(station)
        }
        try context.save()

        let storage = EntityStorage<StationEntityImpl, StationFilter>(
            modelContext: context,
            strategy: .station
        )
        let all = try context.fetch(FetchDescriptor<StationEntityImpl>())

        for (description, filter) in Self.stationMatrix {
            let viaSQLite = try storage.fetchFiltered(filter).map(\.id)
            let viaMemory = storage.filtered(filter, in: all).map(\.id)
            #expect(viaSQLite == viaMemory, "station filter: \(description)")
        }
    }

    @Test
    func facetFiltersMatchBetweenSQLiteAndMemory() throws {
        let container = try StorageContainer.create(isInMemory: true)
        let context = container.mainContext
        for country in Self.countries {
            context.insert(country)
        }
        try context.save()

        let storage = EntityStorage<CountryEntityImpl, FacetFilter>(
            modelContext: context,
            strategy: .facet
        )
        let all = try context.fetch(FetchDescriptor<CountryEntityImpl>())

        for (description, filter) in Self.facetMatrix {
            let viaSQLite = try storage.fetchFiltered(filter).map(\.name)
            let viaMemory = storage.filtered(filter, in: all).map(\.name)
            #expect(viaSQLite == viaMemory, "facet filter: \(description)")
        }
    }

    // MARK: - Fixtures

    /// Insertion order equals name order; votes, bitrate and changeCounter are
    /// unique per row so every ordering is fully determined.
    private static let stations: [StationEntityImpl] = [
        .fixture(id: "s1", name: "Alpha", tags: ["jazz", "live"], country: "US",
                 language: "English", votes: 10, bitrate: 128, lastCheckOk: true, changeCounter: 1),
        .fixture(id: "s2", name: "Bravo", tags: ["rock"], country: "GB",
                 language: "Spanish", votes: 40, bitrate: 320, lastCheckOk: false, changeCounter: 4),
        .fixture(id: "s3", name: "Charlie", tags: ["jazz"], country: "US",
                 language: "English", votes: 25, bitrate: 192, lastCheckOk: true, changeCounter: 2),
        .fixture(id: "s4", name: "Delta", tags: ["chill"], country: "FR",
                 language: "French", votes: 5, bitrate: 64, lastCheckOk: false, changeCounter: 6),
        .fixture(id: "s5", name: "Echo", tags: ["rock", "live"], country: "GB",
                 language: "English", votes: 35, bitrate: 256, lastCheckOk: true, changeCounter: 3),
        .fixture(id: "s6", name: "Foxtrot", tags: ["jazz"], country: "US",
                 language: "Spanish", votes: 15, bitrate: 96, lastCheckOk: false, changeCounter: 5)
    ]

    private static let countries: [CountryEntityImpl] = [
        .fixture(name: "Canada", iso31661: "CA", stationCount: 40),
        .fixture(name: "France", iso31661: "FR", stationCount: 25),
        .fixture(name: "Germany", iso31661: "DE", stationCount: 60),
        .fixture(name: "Japan", iso31661: "JP", stationCount: 10),
        .fixture(name: "United Kingdom", iso31661: "GB", stationCount: 5),
        .fixture(name: "United States", iso31661: "US", stationCount: 100)
    ]

    // MARK: - Matrices

    /// One row per (predicate pushdown, ordering, windowing) combination,
    /// including every `postProcess` route: `tag` and `.lastCheckOk`.
    private static let stationMatrix: [(String, StationFilter)] = {
        var matrix: [(String, StationFilter)] = []

        var empty = StationFilter.empty
        matrix.append(("empty", empty))

        var byName = StationFilter.empty
        byName.name = "a"
        matrix.append(("name contains 'a'", byName))

        var byCountry = StationFilter.empty
        byCountry.country = "US"
        matrix.append(("country US", byCountry))

        var byCountryLanguage = StationFilter.empty
        byCountryLanguage.country = "US"
        byCountryLanguage.language = "English"
        matrix.append(("country US + language English", byCountryLanguage))

        var combined = StationFilter.empty
        combined.name = "t"
        combined.country = "US"
        combined.language = "English"
        matrix.append(("name + country + language", combined))

        var byTag = StationFilter.empty
        byTag.tag = "jazz"
        matrix.append(("tag jazz (postProcess)", byTag))

        var tagAndName = StationFilter.empty
        tagAndName.tag = "rock"
        tagAndName.name = "e"
        matrix.append(("tag + name (postProcess)", tagAndName))

        var byVotes = StationFilter.empty
        byVotes.orderBy = .votes
        matrix.append(("order votes", byVotes))

        var byVotesReversed = StationFilter.empty
        byVotesReversed.orderBy = .votes
        byVotesReversed.reverse = true
        matrix.append(("order votes reversed", byVotesReversed))

        var byBitrateFiltered = StationFilter.empty
        byBitrateFiltered.name = "o"
        byBitrateFiltered.orderBy = .bitrate
        matrix.append(("name + order bitrate", byBitrateFiltered))

        var byChangeCounter = StationFilter.empty
        byChangeCounter.orderBy = .changeCounter
        byChangeCounter.reverse = true
        matrix.append(("order changeCounter reversed", byChangeCounter))

        var byLastCheckOk = StationFilter.empty
        byLastCheckOk.orderBy = .lastCheckOk
        matrix.append(("order lastCheckOk (postProcess)", byLastCheckOk))

        var lastCheckWithTag = StationFilter.empty
        lastCheckWithTag.orderBy = .lastCheckOk
        lastCheckWithTag.tag = "live"
        matrix.append(("tag + order lastCheckOk (postProcess)", lastCheckWithTag))

        var lastCheckFiltered = StationFilter.empty
        lastCheckFiltered.orderBy = .lastCheckOk
        lastCheckFiltered.country = "GB"
        lastCheckFiltered.name = "e"
        matrix.append(("name + country + order lastCheckOk", lastCheckFiltered))

        var windowed = StationFilter.empty
        windowed.limit = 2
        windowed.offset = 1
        matrix.append(("limit 2 offset 1", windowed))

        var windowedFiltered = StationFilter.empty
        windowedFiltered.country = "US"
        windowedFiltered.orderBy = .votes
        windowedFiltered.limit = 3
        windowedFiltered.offset = 1
        matrix.append(("country + order votes + window", windowedFiltered))

        var windowedPostProcess = StationFilter.empty
        windowedPostProcess.tag = "jazz"
        windowedPostProcess.limit = 2
        windowedPostProcess.offset = 1
        matrix.append(("tag + window (deferred window)", windowedPostProcess))

        var windowedLastCheck = StationFilter.empty
        windowedLastCheck.orderBy = .lastCheckOk
        windowedLastCheck.limit = 3
        windowedLastCheck.offset = 2
        matrix.append(("lastCheckOk + window (deferred window)", windowedLastCheck))

        var zeroLimit = StationFilter.empty
        zeroLimit.limit = 0
        matrix.append(("limit 0 means no limit", zeroLimit))

        var offsetBeyondCount = StationFilter.empty
        offsetBeyondCount.offset = 10
        matrix.append(("offset beyond row count", offsetBeyondCount))

        return matrix
    }()

    private static let facetMatrix: [(String, FacetFilter)] = {
        var matrix: [(String, FacetFilter)] = []

        matrix.append(("empty", .empty))

        var byName = FacetFilter.empty
        byName.name = "e"
        matrix.append(("name contains 'e'", byName))

        var byMinCount = FacetFilter.empty
        byMinCount.minStationCount = 40
        matrix.append(("minStationCount 40", byMinCount))

        var combined = FacetFilter.empty
        combined.name = "u"
        combined.minStationCount = 5
        matrix.append(("name + minStationCount", combined))

        var byCount = FacetFilter.empty
        byCount.orderBy = .stationCount
        matrix.append(("order stationCount", byCount))

        var byCountReversed = FacetFilter.empty
        byCountReversed.orderBy = .stationCount
        byCountReversed.reverse = true
        matrix.append(("order stationCount reversed", byCountReversed))

        var filteredOrdered = FacetFilter.empty
        filteredOrdered.name = "e"
        filteredOrdered.orderBy = .stationCount
        matrix.append(("name + order stationCount", filteredOrdered))

        var constrained = FacetFilter.empty
        constrained.minStationCount = 10
        constrained.orderBy = .stationCount
        constrained.reverse = true
        matrix.append(("minStationCount + order reversed", constrained))

        return matrix
    }()
}
