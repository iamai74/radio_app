import Foundation

/// A protocol defining the requirements for interacting with tag endpoints.
///
/// `fetch` is the single requirement; the two methods callers use are default
/// implementations, so conformers and test doubles stay minimal.
public protocol TagsEndpointProtocol: Sendable {
    /// Performs a route of the service and returns the decoded tags.
    /// - Parameters:
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The tags the service answered with.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Tag]
}

public extension TagsEndpointProtocol {
    /// Fetches a list of all tags.
    /// - Returns: An array of Tag objects.
    /// - Throws: An error if the request fails.
    func getTags() async throws -> [any Tag] {
        try await fetch(.tags, queryItems: [])
    }

    /// Fetches a list of tags that match the given filter.
    /// - Parameter filter: The filter to apply to the results.
    /// - Returns: An array of Tag objects matching the filter.
    /// - Throws: An error if the request fails.
    func getTags(withFilter filter: String) async throws -> [any Tag] {
        try await fetch(.tagsByFilter(filter: filter), queryItems: [])
    }
}
