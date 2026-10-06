import Foundation

/// The endpoints the facade exposes.
///
/// A component is the package's composition root: it is the single place that turns a
/// configuration and a transport into concrete endpoints, so every consumer builds the
/// same graph no matter which initialiser it used. One ``RequestExecutor`` carries the
/// request policy and the transport and is shared by every endpoint of the client.
package protocol RadioBrowserAPIComponentProtocol: Sendable {
    var stations: StationsEndpointProtocol { get }
    var countries: any ResourceFiltering<Country> { get }
    var languages: any ResourceFiltering<Language> { get }
    var tags: any ResourceFiltering<Tag> { get }
    var codecs: any ResourceEndpointProtocol<Codec> { get }
}

internal struct RadioBrowserAPIComponent: RadioBrowserAPIComponentProtocol {
    let stations: StationsEndpointProtocol
    let countries: any ResourceFiltering<Country>
    let languages: any ResourceFiltering<Language>
    let tags: any ResourceFiltering<Tag>
    let codecs: any ResourceEndpointProtocol<Codec>

    /// - Parameters:
    ///   - configuration: The mirrors and request policy every endpoint uses.
    ///   - networkClient: The transport to perform the requests. `nil` builds the default
    ///     one, configured with the user agent of the configuration.
    init(configuration: RadioBrowserConfiguration = .default, networkClient: NetworkClientProtocol? = nil) {
        let executor = RequestExecutor(
            networkClient: networkClient ?? DefaultNetworkClient(),
            configuration: configuration
        )

        self.stations = StationsEndpoint(executor: executor)
        self.countries = CountriesEndpoint(executor: executor)
        self.languages = LanguagesEndpoint(executor: executor)
        self.tags = TagsEndpoint(executor: executor)
        self.codecs = CodecsEndpoint(executor: executor)
    }
}
