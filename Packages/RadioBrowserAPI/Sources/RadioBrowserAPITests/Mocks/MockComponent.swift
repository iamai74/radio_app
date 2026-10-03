import Foundation
@testable import RadioBrowserAPI

/// DI component exposing test doubles, used to verify that `RadioBrowserAPI` sources
/// its endpoints from the injected component.
struct MockComponent: RadioBrowserApiComponentProtocol {
    let stations: StationsEndpointProtocol = MockStationsEndpoint()
    let countries: CountriesEndpointProtocol = MockCountriesEndpoint()
    let languages: LanguagesEndpointProtocol = MockLanguagesEndpoint()
    let tags: TagsEndpointProtocol = MockTagsEndpoint()
    let codecs: CodecsEndpointProtocol = MockCodecsEndpoint()

    var radioBrowserAPI: RadioBrowserAPI {
        RadioBrowserAPI(component: self)
    }
}

/// Satisfies the package-internal dependency contract with a stubbed network client.
struct StubDependency: RadioBrowserApiDependency {
    let networkClient: NetworkClientProtocol
}
