import Foundation
import RadioBrowserAPI

/// The package's `Tag` under a private name: `Swift Testing` exports its own `Tag`, which
/// shadows the model in every test file that imports both modules.
typealias RadioTag = Tag

/// DI component exposing test doubles, used to verify that `RadioBrowserAPI` sources
/// its endpoints from the injected component.
struct MockComponent: RadioBrowserAPIComponentProtocol {
    let stations: StationsEndpointProtocol = MockStationsEndpoint()
    let countries: any ResourceFiltering<Country> = MockResourceEndpoint<any Country>()
    let languages: any ResourceFiltering<Language> = MockResourceEndpoint<any Language>()
    let tags: any ResourceFiltering<Tag> = MockResourceEndpoint<any Tag>()
    let codecs: any ResourceEndpointProtocol<Codec> = MockResourceEndpoint<any Codec>()
}
