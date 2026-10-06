import Foundation

/// The endpoints the facade exposes.
///
/// A component is the package's composition root: it is the single place that turns a
/// configuration and a transport into concrete endpoints, so every consumer builds the
/// same graph no matter which initialiser it used.
package protocol RadioBrowserApiComponentProtocol: Sendable {
    var stations: StationsEndpointProtocol { get }
    var countries: CountriesEndpointProtocol { get }
    var languages: LanguagesEndpointProtocol { get }
    var tags: TagsEndpointProtocol { get }
    var codecs: CodecsEndpointProtocol { get }
}

internal struct RadioBrowserApiComponent: RadioBrowserApiComponentProtocol {
    let stations: StationsEndpointProtocol
    let countries: CountriesEndpointProtocol
    let languages: LanguagesEndpointProtocol
    let tags: TagsEndpointProtocol
    let codecs: CodecsEndpointProtocol

    /// - Parameters:
    ///   - configuration: The mirrors and request policy every endpoint uses.
    ///   - networkClient: The transport to perform the requests. `nil` builds the default
    ///     one, configured with the user agent of the configuration.
    init(configuration: RadioBrowserConfiguration = .default, networkClient: NetworkClientProtocol? = nil) {
        let networkClient = networkClient ?? DefaultNetworkClient(userAgent: configuration.userAgent)

        self.stations = StationsEndpoint(networkClient: networkClient, configuration: configuration)
        self.countries = CountriesEndpoint(networkClient: networkClient, configuration: configuration)
        self.languages = LanguagesEndpoint(networkClient: networkClient, configuration: configuration)
        self.tags = TagsEndpoint(networkClient: networkClient, configuration: configuration)
        self.codecs = CodecsEndpoint(networkClient: networkClient, configuration: configuration)
    }
}
