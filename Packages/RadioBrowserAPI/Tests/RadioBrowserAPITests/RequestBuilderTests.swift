import Testing
import Foundation
@testable import RadioBrowserAPI

/// The whole request policy of a client — URL, query, timeout, cache policy and the
/// `User-Agent` the service asks for — is applied by `RequestBuilder`, in one place,
/// before the transport sees the request.
struct RequestBuilderTests {
    private let mirror = RadioBrowserConfiguration.defaultBaseURL

    @Test
    func requestCarriesTheUserAgentOfTheConfiguration() throws {
        let builder = RequestBuilder(
            mirror: mirror,
            configuration: RadioBrowserConfiguration(userAgent: "MyApp/1.0 (contact@example.com)")
        )

        let request = try #require(builder.request(for: APIEndpoint.stations, queryItems: []))

        #expect(request.value(forHTTPHeaderField: "User-Agent") == "MyApp/1.0 (contact@example.com)")
    }

    @Test
    func requestCarriesTheTimeoutAndCachePolicyOfTheConfiguration() throws {
        let builder = RequestBuilder(
            mirror: mirror,
            configuration: RadioBrowserConfiguration(timeout: 12, cachePolicy: .reloadIgnoringLocalCacheData)
        )

        let request = try #require(builder.request(for: APIEndpoint.stations, queryItems: []))

        #expect(request.timeoutInterval == 12)
        #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
    }

    @Test
    func requestMergesRouteAndCallerQueryItems() throws {
        let builder = RequestBuilder(mirror: mirror, configuration: .default)

        let request = try #require(builder.request(
            for: APIEndpoint.stationsSearch(query: "jazz"),
            queryItems: [URLQueryItem(name: "limit", value: "5")]
        ))

        #expect(request.url?.path == "/json/stations/search")
        #expect(request.url?.queryPairs == ["q=jazz", "limit=5"])
    }

    @Test
    func requestIsNilWhenTheMirrorCannotFormAnURL() {
        let builder = RequestBuilder(
            mirror: URL(string: "ftp://api.example.com") ?? mirror,
            configuration: .default
        )

        #expect(builder.request(for: APIEndpoint.stations, queryItems: []) == nil)
    }

    /// The policy travels with the request through the whole pipeline: an endpoint's
    /// recording double sees the user agent the configuration declared.
    @Test
    func endpointRequestReachesTheTransportWithItsUserAgent() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let configuration = RadioBrowserConfiguration(userAgent: "RadioApp/Tests")
        let endpoint = StationsEndpoint(networkClient: client, configuration: configuration)

        _ = try await endpoint.getAllStations()

        let request = try #require(client.lastRequest)
        #expect(request.value(forHTTPHeaderField: "User-Agent") == "RadioApp/Tests")
        #expect(request.timeoutInterval == configuration.timeout)
        #expect(request.cachePolicy == configuration.cachePolicy)
    }
}
