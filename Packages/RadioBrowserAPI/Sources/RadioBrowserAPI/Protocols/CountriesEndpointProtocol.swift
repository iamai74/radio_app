import Foundation

/// A protocol defining the requirements for interacting with country endpoints.
///
/// `fetch` is the single requirement; the two methods callers use are default
/// implementations, so conformers and test doubles stay minimal.
public protocol CountriesEndpointProtocol: Sendable {
    /// Performs a route of the service and returns the decoded countries.
    /// - Parameters:
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The countries the service answered with.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Country]
}

public extension CountriesEndpointProtocol {
    /// Fetches a list of all countries.
    /// - Returns: An array of Country objects.
    /// - Throws: An error if the request fails.
    func getCountries() async throws -> [any Country] {
        try await fetch(.countries, queryItems: [])
    }

    /// Fetches a list of countries that match the given filter.
    /// - Parameter filter: The filter to apply to the results.
    /// - Returns: An array of Country objects matching the filter.
    /// - Throws: An error if the request fails.
    func getCountries(withFilter filter: String) async throws -> [any Country] {
        try await fetch(.countriesByFilter(filter: filter), queryItems: [])
    }
}
