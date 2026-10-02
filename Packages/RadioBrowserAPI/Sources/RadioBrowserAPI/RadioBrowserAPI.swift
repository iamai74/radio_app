import Foundation

public final class RadioBrowserAPI {
    public let stations: StationsEndpointProtocol
    public let countries: CountriesEndpointProtocol
    public let languages: LanguagesEndpointProtocol
    public let tags: TagsEndpointProtocol
    public let codecs: CodecsEndpointProtocol

    public init(component: RadioBrowserApiComponent) {
        self.stations = component.stations
        self.countries = component.countries
        self.languages = component.languages
        self.tags = component.tags
        self.codecs = component.codecs
    }

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
