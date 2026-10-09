import Testing
import Foundation
@testable import RadioBrowserAPI

/// Tests for `RadioBrowserAPI` itself: how it exposes and wires its endpoints.
struct RadioBrowserAPITests {

    // MARK: - Initialization

    @Test
    func initializationWithNetworkClientBuildsConcreteEndpoints() {
        let api = RadioBrowserAPI(networkClient: MockNetworkClient(data: Data()))

        #expect(api.stations is StationsEndpoint)
        #expect(api.countries is CountriesEndpoint)
        #expect(api.languages is LanguagesEndpoint)
        #expect(api.tags is TagsEndpoint)
        #expect(api.codecs is CodecsEndpoint)
    }

    // MARK: - Fixtures

    @Test
    func missingMockResourceIsReported() {
        #expect(throws: MockData.LoadError.self) {
            try MockData.json(named: "does-not-exist")
        }
    }
}
