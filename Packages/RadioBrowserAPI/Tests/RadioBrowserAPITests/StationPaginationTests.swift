import Foundation
import Testing
@testable import RadioBrowserAPI

/// The paging state machine of ``StationPages``: what ends a walk, how the offset advances,
/// and which parts of the criteria survive the per page rewrite.
///
/// The walk is only exercised from `ResilienceTests` inside two loops; this suite pins the
/// states themselves, because a paging bug surfaces as quietly skipped stations.
struct StationPaginationTests {
    private let stationsFixtureCount = 3

    // MARK: - Laziness

    @Test
    func nothingIsRequestedBeforeTheWalkIsConsumed() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let endpoint = StationsEndpoint(networkClient: client)
        let pages = endpoint.pages(matching: StationQuery(), pageSize: 2)

        #expect(client.requests.isEmpty)
        _ = try await pages.first { _ in true }

        #expect(client.requests.count == 1)
    }

    // MARK: - Ending a walk

    @Test
    func anEmptyFirstPageYieldsNothing() async throws {
        let client = MockNetworkClient(data: Data("[]".utf8))
        let endpoint = StationsEndpoint(networkClient: client)

        var pageCount = 0
        for try await _ in endpoint.pages(matching: StationQuery(), pageSize: 2) {
            pageCount += 1
        }

        #expect(pageCount == 0)
        #expect(client.requests.count == 1)
    }

    @Test
    func anEmptyLaterPageEndsTheWalkAfterThePagesBeforeIt() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(script: [.success(payload), .success(Data("[]".utf8))])
        let endpoint = StationsEndpoint(networkClient: client)

        var pageCount = 0
        for try await _ in endpoint.pages(matching: StationQuery(), pageSize: stationsFixtureCount) {
            pageCount += 1
        }

        // A full page keeps the walk alive, the empty answer behind it ends it.
        #expect(pageCount == 1)
        #expect(client.requests.count == 2)
    }

    @Test
    func aPageShorterThanThePageSizeEndsTheWalkWithoutAFollowUpRequest() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(data: payload)
        let endpoint = StationsEndpoint(networkClient: client)

        var pageCount = 0
        for try await page in endpoint.pages(matching: StationQuery(), pageSize: 5) {
            pageCount += 1
            #expect(page.count == stationsFixtureCount)
        }

        #expect(pageCount == 1)
        #expect(client.requests.count == 1)
    }

    @Test
    func aFailureDuringTheWalkPropagatesAndStopsIt() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(script: [.success(payload), .failure(APIError.httpError(500))])
        let endpoint = StationsEndpoint(networkClient: client)

        await #expect(throws: APIError.httpError(500)) {
            for try await _ in endpoint.pages(matching: StationQuery(), pageSize: 1) {
                // Consume every page until the scripted failure answers.
            }
        }
    }

    // MARK: - Offset

    /// The offset advances by the number of stations *received*, not by the page size:
    /// a service answering with more rows than asked for would otherwise skip stations.
    @Test
    func theOffsetAdvancesByTheNumberOfStationsReceived() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(script: [.success(payload), .success(payload), .success(Data("[]".utf8))])
        let endpoint = StationsEndpoint(networkClient: client)

        var pageCount = 0
        for try await _ in endpoint.pages(matching: StationQuery(), pageSize: stationsFixtureCount) {
            pageCount += 1
        }

        #expect(pageCount == 2)

        let offsets = client.requests.compactMap { request in
            request.url?.queryPairs.first { $0.hasPrefix("offset=") }
        }
        #expect(offsets == ["offset=0", "offset=3", "offset=6"])
    }

    @Test
    func theWalkStartsAtTheOffsetOfTheQuery() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(data: payload)
        let endpoint = StationsEndpoint(networkClient: client)

        _ = try await endpoint.pages(matching: StationQuery(offset: 40), pageSize: stationsFixtureCount)
            .first { _ in true }

        #expect(try lastRequestURL(of: client).queryPairs.contains("offset=40"))
    }

    // MARK: - Criteria

    /// `limit` and `offset` are rewritten per page, every other criterion of the walk is
    /// carried along — the walk filters the way the caller asked, page after page.
    @Test
    func criteriaOfTheQuerySurviveThePerPageRewrite() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(data: payload)
        let endpoint = StationsEndpoint(networkClient: client)
        let query = StationQuery(
            country: "United States",
            language: "english",
            tag: "rock",
            name: "Radio",
            limit: 99,
            offset: 7,
            hideBreaks: true,
            order: .votes,
            reverse: true
        )

        _ = try await endpoint.pages(matching: query, pageSize: 2).first { _ in true }

        #expect(try lastRequestURL(of: client).queryPairs == [
            "country=United States",
            "language=english",
            "tag=rock",
            "name=Radio",
            "limit=2",
            "offset=7",
            "hide_breaks=true",
            "order=votes",
            "reverse=true"
        ])
    }

    // MARK: - Re-iteration

    /// A sequence is not a one shot: a second iteration starts a fresh walk from the
    /// beginning of the same criteria.
    @Test
    func everyIterationWalksFromTheStartAgain() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(data: payload)
        let endpoint = StationsEndpoint(networkClient: client)
        // Bigger than the fixture, so every walk ends after its first page.
        let pages = endpoint.pages(matching: StationQuery(), pageSize: 5)

        for try await _ in pages {}
        for try await _ in pages {}

        #expect(client.requests.count == 2)
        #expect(client.requests.allSatisfy { $0.url?.queryPairs.contains("offset=0") == true })
    }
}
