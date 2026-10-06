import Foundation

/// Endpoint for interacting with countries.
final class CountriesEndpoint: BaseEndpoint<CountryObject>, CountriesEndpointProtocol, @unchecked Sendable {
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Country] {
        try await fetch(endpoint: endpoint, queryItems: queryItems)
    }
}
