import Testing
import Foundation
@testable import RadioBrowserAPI

/// Tests for the production `StationsEndpoint`, driven by a recording network double.
struct StationsEndpointTests {
    private let host = "https://de2.api.radio-browser.info"

    // MARK: - getStations

    @Test
    func getStationsBuildsFilterQuery() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let endpoint = StationsEndpoint(networkClient: client)

        let stations = try await endpoint.getStations(matching: StationQuery(
            country: "United States",
            language: "english",
            tag: "rock",
            name: "Radio",
            limit: 50,
            offset: 10,
            hideBreaks: true,
            order: .votes,
            reverse: true
        ))

        #expect(stations.map(\.id) == ["7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60", "second-station-id", "third-station-id"])

        let url = try lastRequestURL(of: client)
        #expect(url.absoluteString.hasPrefix("\(host)/json/stations?"))
        #expect(url.path == "/json/stations")
        #expect(url.queryPairs == [
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

    @Test
    func getStationsUsesDefaultsForOmittedFilters() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let endpoint = StationsEndpoint(networkClient: client)

        _ = try await endpoint.getStations()

        #expect(try lastRequestURL(of: client).queryPairs == [
            "limit=100",
            "offset=0",
            "hide_breaks=false",
            "order=name",
            "reverse=false"
        ])
    }

    @Test
    func getStationsSkipsEmptyFilterValues() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let endpoint = StationsEndpoint(networkClient: client)

        _ = try await endpoint.getStations(matching: StationQuery(country: "", language: "", tag: "", name: ""))

        #expect(try lastRequestURL(of: client).queryPairs == [
            "limit=100",
            "offset=0",
            "hide_breaks=false",
            "order=name",
            "reverse=false"
        ])
    }

    @Test
    func getAllStationsSendsNoQuery() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let endpoint = StationsEndpoint(networkClient: client)

        let stations = try await endpoint.getAllStations()

        #expect(stations.count == 3)
        #expect(stations.first?.name == "Test Radio Station")
        #expect(try lastRequestURL(of: client).absoluteString == "\(host)/json/stations")
    }

    // MARK: - Single station

    /// Radio Browser has no single station route: `/json/stations/{id}` answers 404, while
    /// `/json/stations/byuuid/{id}` answers with a list.
    @Test
    func getStationByIDDecodesFirstItemOfTheList() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "station-by-id"))
        let endpoint = StationsEndpoint(networkClient: client)

        let station = try #require(try await endpoint.getStation(byID: "7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60"))

        #expect(station.id == "7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60")
        #expect(station.name == "Test Radio Station")
        #expect(try lastRequestURL(of: client).path == "/json/stations/byuuid/7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60")
    }

    @Test
    func getStationByIDReturnsNilForUnknownStation() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations-empty"))
        let endpoint = StationsEndpoint(networkClient: client)

        let station = try await endpoint.getStation(byID: "unknown-station-id")

        #expect(station == nil)
        #expect(try lastRequestURL(of: client).path == "/json/stations/byuuid/unknown-station-id")
    }

    @Test
    func getStationByIDFailsOnMalformedListPayload() async throws {
        let client = MockNetworkClient(data: Data(#"{"stationuuid": "not-a-list"}"#.utf8))
        let endpoint = StationsEndpoint(networkClient: client)

        await #expect(throws: APIError.self) {
            _ = try await endpoint.getStation(byID: "7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60")
        }
    }

    // MARK: - Lookups

    @Test
    func searchStationsSendsQueryAndLimit() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let endpoint = StationsEndpoint(networkClient: client)

        let stations = try await endpoint.searchStations(query: "jazz", limit: 5)

        #expect(stations.count == 3)

        let url = try lastRequestURL(of: client)
        #expect(url.path == "/json/stations/search")
        #expect(url.queryPairs == ["q=jazz", "limit=5"])
    }

    /// The service's filter routes stay reachable as values; querying them is the job of
    /// `StationQuery` — the endpoint itself only takes criteria, not a method per filter.
    @Test
    func filterRoutesKeepTheirPaths() {
        #expect(APIEndpoint.stationsByCountry(countryCode: "United States").path == "/json/stations/bycountry/United States")
        #expect(APIEndpoint.stationsByLanguage(languageCode: "english").path == "/json/stations/bylanguage/english")
        #expect(APIEndpoint.stationsByTag(tag: "rock").path == "/json/stations/bytag/rock")
        #expect(APIEndpoint.stationsByCountry(countryCode: "US").queryItems.isEmpty)
    }

    @Test
    func stationCriteriaGoThroughStationQuery() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "stations"))
        let endpoint = StationsEndpoint(networkClient: client)

        _ = try await endpoint.getStations(matching: StationQuery(country: "United States", limit: 5))

        #expect(try lastRequestURL(of: client).path == "/json/stations")
        #expect(try lastRequestURL(of: client).queryPairs.contains("country=United States"))
        #expect(try lastRequestURL(of: client).queryPairs.contains("limit=5"))
    }

    // MARK: - Failures

    @Test
    func malformedPayloadFailsWithDecodingError() async throws {
        let client = MockNetworkClient(data: Data(#"{"unexpected": true}"#.utf8))
        let endpoint = StationsEndpoint(networkClient: client)

        do {
            _ = try await endpoint.getAllStations()
            Issue.record("Expected getAllStations() to fail on a malformed payload")
        } catch let error as APIError {
            guard case .decodingFailed = error else {
                Issue.record("Expected APIError.decodingFailed, got \(error)")
                return
            }
        }
    }

    @Test
    func malformedBaseURLFailsWithInvalidURLError() async throws {
        let client = MockNetworkClient(data: Data())
        let configuration = RadioBrowserConfiguration(baseURLs: [
            URL(string: "ftp://api.example.com") ?? RadioBrowserConfiguration.defaultBaseURL
        ])
        let endpoint = StationsEndpoint(networkClient: client, configuration: configuration)

        do {
            _ = try await endpoint.getAllStations()
            Issue.record("Expected getAllStations() to fail before performing a request")
        } catch let error as APIError {
            guard case .invalidURL = error else {
                Issue.record("Expected APIError.invalidURL, got \(error)")
                return
            }
        }

        #expect(client.requests.isEmpty)
    }

    @Test
    func networkFailureIsReportedAsAPIError() async throws {
        let endpoint = StationsEndpoint(networkClient: MockNetworkClient(error: URLError(.notConnectedToInternet)))

        do {
            _ = try await endpoint.getAllStations()
            Issue.record("Expected getAllStations() to fail on a transport error")
        } catch let error as APIError {
            guard case .networkFailed(let underlying) = error else {
                Issue.record("Expected APIError.networkFailed, got \(error)")
                return
            }
            #expect((underlying as? URLError)?.code == .notConnectedToInternet)
        }
    }

    @Test
    func httpErrorFromClientIsNotRewrapped() async throws {
        let endpoint = StationsEndpoint(networkClient: MockNetworkClient(error: APIError.httpError(404)))

        do {
            _ = try await endpoint.getAllStations()
            Issue.record("Expected getAllStations() to fail on an HTTP error")
        } catch let error as APIError {
            guard case .httpError(let statusCode) = error else {
                Issue.record("Expected APIError.httpError to be preserved, got \(error)")
                return
            }
            #expect(statusCode == 404)
        }
    }
}
