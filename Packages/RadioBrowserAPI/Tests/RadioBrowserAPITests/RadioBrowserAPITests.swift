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

    @Test
    func initializationWithComponentTakesEndpointsFromComponent() {
        let component = MockComponent()
        let api = RadioBrowserAPI(component: component)

        #expect(api.stations is MockStationsEndpoint)
        #expect(api.countries is MockCountriesEndpoint)
        #expect(api.languages is MockLanguagesEndpoint)
        #expect(api.tags is MockTagsEndpoint)
        #expect(api.codecs is MockCodecsEndpoint)
    }

    @Test
    func componentBuildsEndpointsForInjectedNetworkClient() {
        let component = RadioBrowserApiComponent(
            networkClient: MockNetworkClient(data: Data())
        )

        #expect(component.stations is StationsEndpoint)
        #expect(component.countries is CountriesEndpoint)
        #expect(component.languages is LanguagesEndpoint)
        #expect(component.tags is TagsEndpoint)
        #expect(component.codecs is CodecsEndpoint)
    }

    // MARK: - Fixtures

    @Test
    func missingMockResourceIsReported() {
        #expect(throws: MockData.LoadError.self) {
            try MockData.json(named: "does-not-exist")
        }
    }
}
