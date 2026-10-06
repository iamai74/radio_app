import Foundation

/// A protocol defining the requirements for interacting with language endpoints.
///
/// `fetch` is the single requirement; the two methods callers use are default
/// implementations, so conformers and test doubles stay minimal.
public protocol LanguagesEndpointProtocol: Sendable {
    /// Performs a route of the service and returns the decoded languages.
    /// - Parameters:
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The languages the service answered with.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Language]
}

public extension LanguagesEndpointProtocol {
    /// Fetches a list of all languages.
    /// - Returns: An array of Language objects.
    /// - Throws: An error if the request fails.
    func getLanguages() async throws -> [any Language] {
        try await fetch(.languages, queryItems: [])
    }

    /// Fetches a list of languages that match the given filter.
    /// - Parameter filter: The filter to apply to the results.
    /// - Returns: An array of Language objects matching the filter.
    /// - Throws: An error if the request fails.
    func getLanguages(withFilter filter: String) async throws -> [any Language] {
        try await fetch(.languagesByFilter(filter: filter), queryItems: [])
    }
}
