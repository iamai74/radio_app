import Foundation

/// The main entry point for accessing the Radio Browser API.
/// This value provides access to various endpoints such as stations, countries, languages,
/// tags and codecs, and to the request pipeline behind them.
public struct RadioBrowserAPI: Sendable {
    /// Endpoint for interacting with radio stations.
    public let stations: StationsEndpointProtocol
    /// Endpoint for interacting with countries.
    public let countries: any ResourceFiltering<Country>
    /// Endpoint for interacting with languages.
    public let languages: any ResourceFiltering<Language>
    /// Endpoint for interacting with tags.
    public let tags: any ResourceFiltering<StationTag>
    /// Endpoint for interacting with audio codecs.
    public let codecs: any ResourceEndpointProtocol<Codec>

    /// The request pipeline every endpoint of this client shares: the place to run a route
    /// the package does not know about yet (see ``EndpointDefinition``) through the same
    /// mirrors, transport policy and decoding the built-in endpoints use.
    public let executor: any EndpointExecuting

    /// Initializes the API with a dependency injection component.
    /// - Parameter component: The DI component containing necessary dependencies.
    package init(component: RadioBrowserAPIComponentProtocol) {
        self.stations = component.stations
        self.countries = component.countries
        self.languages = component.languages
        self.tags = component.tags
        self.codecs = component.codecs
        self.executor = component.executor
    }

    /// Initializes the API from a configuration.
    ///
    /// This is the entry point every consumer should use: the configuration decides which
    /// mirrors are tried, which user agent is sent and how requests are timed out, while
    /// the transport can still be replaced wholesale.
    /// - Parameters:
    ///   - configuration: The mirrors and request policy to use.
    ///   - networkClient: The transport performing the requests. Pass `nil` — the default —
    ///     to let the package build it, or inject your own to take over transport.
    public init(
        configuration: RadioBrowserConfiguration = .default,
        networkClient: NetworkClientProtocol? = nil
    ) {
        self.init(
            component: RadioBrowserAPIComponent(configuration: configuration, networkClient: networkClient)
        )
    }
}
