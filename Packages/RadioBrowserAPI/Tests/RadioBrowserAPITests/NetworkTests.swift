import Testing
import Foundation
@testable import RadioBrowserAPI

struct NetworkTests {

    // MARK: - URLBuilder Tests

    @Test
    func urlBuilderBuildWithPath() throws {
        let url = try #require(URLBuilder().build(path: "/stations"))

        #expect(url.absoluteString == "https://de2.api.radio-browser.info/stations")
    }

    @Test
    func urlBuilderUsesCustomBaseURL() throws {
        let url = try #require(URLBuilder(baseURL: "https://api.example.com").build(path: "/json/stations"))

        #expect(url.absoluteString == "https://api.example.com/json/stations")
    }

    @Test
    func urlBuilderBuildWithQueryItems() throws {
        let queryItems = [
            URLQueryItem(name: "country", value: "United States"),
            URLQueryItem(name: "limit", value: "100")
        ]
        let url = try #require(URLBuilder().build(path: "/json/stations", queryItems: queryItems))

        #expect(url.queryPairs == ["country=United States", "limit=100"])
    }

    @Test
    func urlBuilderOmitsEmptyQuery() throws {
        let url = try #require(URLBuilder().build(path: "/json/stations"))

        #expect(url.query == nil)
    }

    @Test
    func urlBuilderBuildWithEndpoint() throws {
        let url = try #require(URLBuilder().build(endpoint: APIEndpoint.stations))

        #expect(url.path == "/json/stations")
    }

    @Test
    func urlBuilderBuildWithEndpointUsesEndpointQueryItems() throws {
        let url = try #require(URLBuilder().build(endpoint: APIEndpoint.stationsSearch(query: "jazz")))

        #expect(url.path == "/json/stations/search")
        #expect(url.queryPairs == ["q=jazz"])
    }

    @Test
    func urlBuilderKeepsEndpointQueryItemsWhenAddingMore() throws {
        let queryItems = [URLQueryItem(name: "limit", value: "5")]
        let url = try #require(URLBuilder().build(endpoint: APIEndpoint.stationsSearch(query: "jazz"), queryItems: queryItems))

        #expect(url.queryPairs == ["q=jazz", "limit=5"])
    }

    @Test
    func urlBuilderOverridesEndpointQueryItemsWithTheSameName() throws {
        let queryItems = [URLQueryItem(name: "q", value: "blues"), URLQueryItem(name: "limit", value: "5")]
        let url = try #require(URLBuilder().build(endpoint: APIEndpoint.stationsSearch(query: "jazz"), queryItems: queryItems))

        #expect(url.queryPairs == ["q=blues", "limit=5"])
    }

    @Test(arguments: [
        "https://api.example.com:not-a-port",
        "de2.api.radio-browser.info",
        "ftp://de2.api.radio-browser.info",
        "https://",
        ""
    ])
    func urlBuilderReturnsNilForUnusableBaseURL(baseURL: String) {
        #expect(URLBuilder(baseURL: baseURL).build(path: "/json/stations") == nil)
    }

    // MARK: - APIEndpoint Tests

    @Test(arguments: [
        (APIEndpoint.stations, "/json/stations"),
        (APIEndpoint.stationByID(id: "abc"), "/json/stations/byuuid/abc"),
        (APIEndpoint.stationsSearch(query: "jazz"), "/json/stations/search"),
        (APIEndpoint.stationsByCountry(countryCode: "US"), "/json/stations/bycountry/US"),
        (APIEndpoint.stationsByLanguage(languageCode: "english"), "/json/stations/bylanguage/english"),
        (APIEndpoint.stationsByTag(tag: "rock"), "/json/stations/bytag/rock"),
        (APIEndpoint.countries, "/json/countries"),
        (APIEndpoint.countriesByFilter(filter: "german"), "/json/countries/german"),
        (APIEndpoint.languages, "/json/languages"),
        (APIEndpoint.languagesByFilter(filter: "english"), "/json/languages/english"),
        (APIEndpoint.tags, "/json/tags"),
        (APIEndpoint.tagsByFilter(filter: "rock"), "/json/tags/rock"),
        (APIEndpoint.codecs, "/json/codecs")
    ])
    func apiEndpointPath(endpoint: APIEndpoint, expectedPath: String) {
        #expect(endpoint.path == expectedPath)
    }

    /// `APIEndpoint` carries the raw filter value and the URL builder — which sees every
    /// route of a request — percent encodes it exactly once.
    @Test
    func apiEndpointKeepsPathsRawAndTheBuilderEncodesThem() {
        let builder = URLBuilder()

        #expect(APIEndpoint.stationsByTag(tag: "hip hop").path == "/json/stations/bytag/hip hop")
        #expect(builder.build(endpoint: APIEndpoint.stationsByTag(tag: "hip hop"))?.absoluteString
            == "https://de2.api.radio-browser.info/json/stations/bytag/hip%20hop")

        #expect(APIEndpoint.tagsByFilter(filter: "love songs").path == "/json/tags/love songs")
        #expect(builder.build(endpoint: APIEndpoint.tagsByFilter(filter: "love songs"))?.absoluteString
            == "https://de2.api.radio-browser.info/json/tags/love%20songs")
    }

    @Test
    func apiEndpointQueryItemsAreOnlyDefinedForSearch() {
        #expect(APIEndpoint.stationsSearch(query: "jazz").queryItems.pairs == ["q=jazz"])
        #expect(APIEndpoint.stations.queryItems.isEmpty)
        #expect(APIEndpoint.stationByID(id: "abc").queryItems.isEmpty)
    }

    // MARK: - Mock Network Client Tests

    @Test
    func mockNetworkClientSuccess() async throws {
        let testData = Data("test data".utf8)
        let mockClient = MockNetworkClient(data: testData)
        let request = URLRequest(url: try #require(URL(string: "https://example.com")))

        let resultData = try await mockClient.fetch(request: request)

        #expect(resultData == testData)
        #expect(mockClient.requests.count == 1)
    }

    @Test
    func mockNetworkClientError() async throws {
        let mockClient = MockNetworkClient(error: URLError(.badServerResponse))
        let request = URLRequest(url: try #require(URL(string: "https://example.com")))

        await #expect(throws: URLError.self) {
            _ = try await mockClient.fetch(request: request)
        }

        #expect(mockClient.requests.count == 1)
    }

    @Test
    func mockNetworkClientRecordsEveryRequest() async throws {
        let mockClient = MockNetworkClient(data: Data())
        let first = URLRequest(url: try #require(URL(string: "https://example.com/first")))
        let second = URLRequest(url: try #require(URL(string: "https://example.com/second")))

        _ = try await mockClient.fetch(request: first)
        _ = try await mockClient.fetch(request: second)

        #expect(mockClient.requests.map { $0.url?.absoluteString } == [
            "https://example.com/first",
            "https://example.com/second"
        ])
    }

    @Test
    func mockNetworkClientHasNoRequestsBeforeUse() {
        #expect(MockNetworkClient(data: Data()).requests.isEmpty)
    }
}
