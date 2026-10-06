import Foundation

/// The main entry point for accessing the Radio Browser API.
/// This class provides access to various endpoints such as stations, countries, languages, tags, and codecs.
public final class RadioBrowserAPI {
    /// Endpoint for interacting with radio stations.
    public let stations: StationsEndpointProtocol
    /// Endpoint for interacting with countries.
    public let countries: CountriesEndpointProtocol
    /// Endpoint for interacting with languages.
    public let languages: LanguagesEndpointProtocol
    /// Endpoint for interacting with tags.
    public let tags: TagsEndpointProtocol
    /// Endpoint for interacting with audio codecs.
    public let codecs: CodecsEndpointProtocol

    /// Initializes the API with a dependency injection component.
    /// - Parameter component: The DI component containing necessary dependencies.
    package init(component: RadioBrowserApiComponentProtocol) {
        self.stations = component.stations
        self.countries = component.countries
        self.languages = component.languages
        self.tags = component.tags
        self.codecs = component.codecs
    }

    /// Initializes the API from a configuration.
    ///
    /// This is the entry point every consumer should use: the configuration decides which
    /// mirrors are tried, which user agent is sent and how requests are timed out, while
    /// the transport can still be replaced wholesale.
    /// - Parameters:
    ///   - configuration: The mirrors and request policy to use.
    ///   - networkClient: The transport performing the requests. Pass `nil` — the default —
    ///     to let the configuration build it, or inject your own to take over transport.
    public convenience init(
        configuration: RadioBrowserConfiguration = .default,
        networkClient: NetworkClientProtocol? = nil
    ) {
        self.init(
            component: RadioBrowserApiComponent(configuration: configuration, networkClient: networkClient)
        )
    }
}
