import Foundation
import Testing
@testable import RadioBrowserAPI

/// `StationQuery` is the one value that carries criteria: what it promises is that blank
/// criteria never reach the service, that paging and ordering always do, and that a sort key
/// arrives under the name the API expects.
struct StationQueryTests {

    // MARK: - Defaults

    @Test
    func theDefaultQueryIsTheFirstHundredStationsOrderedByName() {
        #expect(StationQuery() == .default)
        #expect(StationQuery().limit == 100)
        #expect(StationQuery().offset == 0)
        #expect(StationQuery().order == .name)
        #expect(StationQuery().reverse == false)
        #expect(StationQuery().hideBreaks == false)
        #expect(StationQuery().country == nil)
        #expect(StationQuery().language == nil)
        #expect(StationQuery().tag == nil)
        #expect(StationQuery().name == nil)
    }

    @Test
    func theDefaultQuerySendsItsPagingAndOrdering() {
        #expect(StationQuery().queryItems.pairs == [
            "limit=100",
            "offset=0",
            "hide_breaks=false",
            "order=name",
            "reverse=false"
        ])
    }

    // MARK: - Criteria

    @Test
    func criteriaReachTheServiceInAStableOrder() {
        let query = StationQuery(
            country: "United States",
            language: "english",
            tag: "rock",
            name: "Radio",
            limit: 50,
            offset: 10,
            hideBreaks: true,
            order: .votes,
            reverse: true
        )

        #expect(query.queryItems.pairs == [
            "country=United States",
            "language=english",
            "tag=rock",
            "name=Radio",
            "limit=50",
            "offset=10",
            "hide_breaks=true",
            "order=votes",
            "reverse=true"
        ])
    }

    /// Blank criteria — an empty string as well as `nil` — are the service's "no filter"
    /// signal and are dropped rather than sent as `country=`.
    @Test(arguments: [
        StationQuery(country: "", language: "", tag: "", name: ""),
        StationQuery()
    ])
    func blankCriteriaAreDropped(query: StationQuery) {
        let names = query.queryItems.map(\.name)

        #expect(!names.contains("country"))
        #expect(!names.contains("language"))
        #expect(!names.contains("tag"))
        #expect(!names.contains("name"))
        #expect(names.contains("limit"))
        #expect(names.contains("offset"))
    }

    /// A partially filled query keeps the criteria it was given, next to the paging every
    /// request carries.
    @Test
    func partialCriteriaKeepTheirOwnItems() {
        let query = StationQuery(country: "DE", limit: 5)

        #expect(query.queryItems.pairs == [
            "country=DE",
            "limit=5",
            "offset=0",
            "hide_breaks=false",
            "order=name",
            "reverse=false"
        ])
    }

    // MARK: - Sort keys

    /// Every sort key maps to the value the API spells; a misspelled key would silently
    /// order by nothing.
    @Test
    func everySortOrderCarriesItsServiceValue() {
        #expect(StationSortOrder.name.rawValue == "name")
        #expect(StationSortOrder.votes.rawValue == "votes")
        #expect(StationSortOrder.lastCheckTime.rawValue == "lastchecktime")
        #expect(StationSortOrder.clickTimestamp.rawValue == "clicktimestamp")
        #expect(StationSortOrder.lastChangeTime.rawValue == "lastchangetime")
        #expect(StationSortOrder.creationTime.rawValue == "creationtime")
        #expect(StationSortOrder.random.rawValue == "random")
    }

    @Test(arguments: StationSortOrder.allCases)
    func everySortOrderReachesTheOrderItem(order: StationSortOrder) {
        #expect(StationQuery(order: order).queryItems.pairs.contains("order=\(order.rawValue)"))
    }

    // MARK: - Value semantics

    @Test
    func queriesAreValuesThatCompareByContent() {
        var query = StationQuery()
        query.limit = 5

        #expect(query != .default)
        #expect(StationQuery().limit == 100)
        #expect(StationQuery(country: "DE") == StationQuery(country: "DE"))
        #expect(StationQuery(country: "DE") != StationQuery(country: "AT"))
    }
}
