import Foundation
@testable import RadioBrowserAPI

/// DI component exposing test doubles, used to verify that `RadioBrowserAPI` sources
/// its endpoints from the injected component.
struct MockComponent: RadioBrowserAPIComponentProtocol {
    let stations: StationsEndpointProtocol = MockStationsEndpoint()
    let countries: any ResourceFiltering<Country> = MockResourceEndpoint<any Country>()
    let languages: any ResourceFiltering<Language> = MockResourceEndpoint<any Language>()
    let tags: any ResourceFiltering<StationTag> = MockResourceEndpoint<any StationTag>()
    let codecs: any ResourceEndpointProtocol<Codec> = MockResourceEndpoint<any Codec>()
    let executor: any EndpointExecuting = RequestExecutor(networkClient: MockNetworkClient(data: Data()))
}
