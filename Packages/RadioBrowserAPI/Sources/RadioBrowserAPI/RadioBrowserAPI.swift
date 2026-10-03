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
    init(component: RadioBrowserApiComponent) {
        self.stations = component.stations
        self.countries = component.countries
        self.languages = component.languages
        self.tags = component.tags
        self.codecs = component.codecs
    }

    /// Initializes the API with a provided network client.
    /// - Parameter networkClient: The network client to use for requests. Defaults to `DefaultNetworkClient`.
    public convenience init(networkClient: NetworkClientProtocol = DefaultNetworkClient()) {
        self.init(
            stations: StationsEndpoint(networkClient: networkClient),
            countries: CountriesEndpoint(networkClient: networkClient),
            languages: LanguagesEndpoint(networkClient: networkClient),
            tags: TagsEndpoint(networkClient: networkClient),
            codecs: CodecsEndpoint(networkClient: networkClient)
        )
    }

    init(
        stations: StationsEndpointProtocol,
        countries: CountriesEndpointProtocol,
        languages: LanguagesEndpointProtocol,
        tags: TagsEndpointProtocol,
        codecs: CodecsEndpointProtocol
    ) {
        self.stations = stations
        self.countries = countries
        self.languages = languages
        self.tags = tags
        self.codecs = codecs
    }
}
