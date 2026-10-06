import Foundation
import RadioBrowserAPI

/// DI component exposing test doubles, used to verify that `RadioBrowserAPI` sources
/// its endpoints from the injected component.
struct MockComponent: RadioBrowserApiComponentProtocol {
    let stations: StationsEndpointProtocol = MockStationsEndpoint()
    let countries: CountriesEndpointProtocol = MockCountriesEndpoint()
    let languages: LanguagesEndpointProtocol = MockLanguagesEndpoint()
    let tags: TagsEndpointProtocol = MockTagsEndpoint()
    let codecs: CodecsEndpointProtocol = MockCodecsEndpoint()
}
