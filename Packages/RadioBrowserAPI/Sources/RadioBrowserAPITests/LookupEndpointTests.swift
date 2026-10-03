import Testing
import Foundation
@testable import RadioBrowserAPI

/// Tests for the countries, languages, tags and codecs endpoints.
///
/// The endpoints are built on their production initialiser, so every request has to hit
/// the default base URL and the recording network double has to return the fixture.
struct LookupEndpointTests {
    private let host = "https://de2.api.radio-browser.info"

    // MARK: - Countries

    @Test
    func getCountriesDecodesList() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "countries"))
        let endpoint = CountriesEndpoint(networkClient: client)

        let countries = try await endpoint.getCountries()

        #expect(countries.map(\.iso31661) == ["US", "DE"])
        #expect(countries.first?.name == "United States")
        #expect(try lastRequestURL(of: client).absoluteString == "\(host)/json/countries")
    }

    @Test
    func getCountriesWithFilterUsesFilterPath() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "countries"))
        let endpoint = CountriesEndpoint(networkClient: client)

        _ = try await endpoint.getCountries(withFilter: "german")

        #expect(try lastRequestURL(of: client).path == "/json/countries/german")
    }

    // MARK: - Languages

    @Test
    func getLanguagesDecodesList() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "languages"))
        let endpoint = LanguagesEndpoint(networkClient: client)

        let languages = try await endpoint.getLanguages()

        #expect(languages.map(\.name) == ["English", "German"])
        #expect(languages.first?.stationCount == 3200)
        #expect(try lastRequestURL(of: client).absoluteString == "\(host)/json/languages")
    }

    @Test
    func getLanguagesWithFilterUsesFilterPath() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "languages"))
        let endpoint = LanguagesEndpoint(networkClient: client)

        _ = try await endpoint.getLanguages(withFilter: "english")

        #expect(try lastRequestURL(of: client).path == "/json/languages/english")
    }

    // MARK: - Tags

    @Test
    func getTagsDecodesList() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "tags"))
        let endpoint = TagsEndpoint(networkClient: client)

        let tags = try await endpoint.getTags()

        #expect(tags.map(\.name) == ["rock", "jazz"])
        #expect(tags.last?.stationCount == 320)
        #expect(try lastRequestURL(of: client).absoluteString == "\(host)/json/tags")
    }

    @Test
    func getTagsWithFilterUsesFilterPath() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "tags"))
        let endpoint = TagsEndpoint(networkClient: client)

        _ = try await endpoint.getTags(withFilter: "rock")

        #expect(try lastRequestURL(of: client).path == "/json/tags/rock")
    }

    // MARK: - Codecs

    @Test
    func getAudioCodecsDecodesList() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "codecs"))
        let endpoint = CodecsEndpoint(networkClient: client)

        let codecs = try await endpoint.getAudioCodecs()

        #expect(codecs.map(\.name) == ["MP3", "AAC"])
        #expect(codecs.last?.stationCount == 1800)
        #expect(try lastRequestURL(of: client).absoluteString == "\(host)/json/codecs")
    }

    // MARK: - Failures

    @Test
    func malformedPayloadFailsWithDecodingError() async throws {
        let client = MockNetworkClient(data: Data("[{}]".utf8))
        let countries = CountriesEndpoint(networkClient: client)
        let languages = LanguagesEndpoint(networkClient: client)
        let tags = TagsEndpoint(networkClient: client)
        let codecs = CodecsEndpoint(networkClient: client)

        await #expect(throws: APIError.self) { _ = try await countries.getCountries() }
        await #expect(throws: APIError.self) { _ = try await languages.getLanguages() }
        await #expect(throws: APIError.self) { _ = try await tags.getTags() }
        await #expect(throws: APIError.self) { _ = try await codecs.getAudioCodecs() }
    }

    @Test
    func networkFailureIsReportedAsAPIError() async throws {
        let client = MockNetworkClient(error: URLError(.timedOut))
        let endpoint = CountriesEndpoint(networkClient: client)

        do {
            _ = try await endpoint.getCountries()
            Issue.record("Expected getCountries() to fail on a transport error")
        } catch let error as APIError {
            guard case .networkFailed = error else {
                Issue.record("Expected APIError.networkFailed, got \(error)")
                return
            }
        }

        #expect(client.requests.count == 1)
    }

    @Test
    func filtersWithSpacesArePercentEncoded() async throws {
        let client = MockNetworkClient(data: try MockData.json(named: "tags"))
        let endpoint = TagsEndpoint(networkClient: client)

        _ = try await endpoint.getTags(withFilter: "hip hop")

        let url = try lastRequestURL(of: client)
        #expect(url.path == "/json/tags/hip hop")
        #expect(url.absoluteString == "\(host)/json/tags/hip%20hop")
    }
}
