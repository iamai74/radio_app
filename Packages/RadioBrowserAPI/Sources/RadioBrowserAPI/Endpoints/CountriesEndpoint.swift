import Foundation

/// Endpoint for interacting with countries.
final class CountriesEndpoint: BaseEndpoint<CountryObject>, CountriesEndpointProtocol {
    public init(networkClient: NetworkClientProtocol) {
        super.init(networkClient: networkClient)
    }

    override init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder, jsonDecoder: JSONDecoderProtocol) {
        super.init(networkClient: networkClient, urlBuilder: urlBuilder, jsonDecoder: jsonDecoder)
    }

    /// Fetches a list of all countries.
    /// - Returns: An array of Country objects.
    /// - Throws: An error if the request fails.
    public func getCountries() async throws -> [any Country] {
        try await fetch(endpoint: .countries, exposing: { $0 })
    }

    /// Fetches a list of countries that match the given filter.
    /// - Parameter filter: The filter to apply to the results.
    /// - Returns: An array of Country objects matching the filter.
    /// - Throws: An error if the request fails.
    public func getCountries(withFilter filter: String) async throws -> [any Country] {
        try await fetch(endpoint: .countriesByFilter(filter: filter), exposing: { $0 })
    }
}
