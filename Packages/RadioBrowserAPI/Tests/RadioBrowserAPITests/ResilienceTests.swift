import Testing
import Foundation
@testable import RadioBrowserAPI

/// Tests for the behaviour that keeps a request alive when the service does not answer:
/// mirror failover and the lazy walk over a result set.
struct ResilienceTests {

    // MARK: - Mirror failover

    @Test
    func unreachableMirrorIsSkippedForTheNextOne() async throws {
        let stations = try MockData.json(named: "stations")
        let client = MockNetworkClient(script: [
            .failure(URLError(.timedOut)),
            .success(stations)
        ])
        let configuration = RadioBrowserConfiguration(
            baseURLs: [
                try #require(URL(string: "https://mirror-one.example.com")),
                try #require(URL(string: "https://mirror-two.example.com"))
            ]
        )
        let endpoint = StationsEndpoint(networkClient: client, configuration: configuration)

        let answer = try await endpoint.getAllStations()

        #expect(answer.count == 3)
        #expect(client.requests.count == 2)
        #expect(client.requests.first?.url?.host == "mirror-one.example.com")
        #expect(client.lastRequest?.url?.host == "mirror-two.example.com")
    }

    @Test
    func aFailureThatCannotBeRetriedStopsTheFailover() async throws {
        let client = MockNetworkClient(script: [
            .failure(APIError.httpError(404)),
            .success(try MockData.json(named: "stations"))
        ])
        let configuration = RadioBrowserConfiguration(
            baseURLs: [
                try #require(URL(string: "https://mirror-one.example.com")),
                try #require(URL(string: "https://mirror-two.example.com"))
            ]
        )
        let endpoint = StationsEndpoint(networkClient: client, configuration: configuration)

        do {
            _ = try await endpoint.getAllStations()
            Issue.record("Expected getAllStations() to fail on a 404")
        } catch let error as APIError {
            #expect(error == .httpError(404))
        }

        #expect(client.requests.count == 1)
    }

    @Test
    func anUnusableMirrorStillFailsWithoutTouchingTheNetwork() async throws {
        let client = MockNetworkClient(data: Data())
        let configuration = RadioBrowserConfiguration(
            baseURLs: [try #require(URL(string: "ftp://mirror-one.example.com"))]
        )
        let endpoint = StationsEndpoint(networkClient: client, configuration: configuration)

        await #expect(throws: APIError.invalidURL) {
            _ = try await endpoint.getAllStations()
        }
        #expect(client.requests.isEmpty)
    }

    // MARK: - Paging

    @Test
    func pagesStopWhenTheServiceAnswersWithAShortPage() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(script: [.success(payload), .success(Data("[]".utf8))])
        let endpoint = StationsEndpoint(networkClient: client)

        var pages: [[any Station]] = []
        for try await page in endpoint.pages(matching: StationQuery(), pageSize: 2) {
            pages.append(page)
        }

        #expect(pages.count == 1)
        #expect(pages[0].count == 3)
        #expect(client.requests.count == 2)

        let secondRequest = client.requests[1]
        #expect(secondRequest.url?.queryPairs == [
            "limit=2",
            "offset=3",
            "hide_breaks=false",
            "order=name",
            "reverse=false"
        ])
    }

    @Test
    func pagesStopWhenTheConsumerStops() async throws {
        let payload = try MockData.json(named: "stations")
        let client = MockNetworkClient(data: payload)
        let endpoint = StationsEndpoint(networkClient: client)

        for try await _ in endpoint.pages(matching: StationQuery(), pageSize: 1) {
            break
        }

        // Nothing is requested before the stream is consumed, and breaking out of the loop
        // cancels the walk instead of draining the result set.
        #expect(client.requests.count == 1)
    }
}
