import Foundation

/// A protocol defining the requirements for interacting with audio codec endpoints.
///
/// `fetch` is the single requirement; the method callers use is a default implementation,
/// so conformers and test doubles stay minimal.
public protocol CodecsEndpointProtocol: Sendable {
    /// Performs a route of the service and returns the decoded codecs.
    /// - Parameters:
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The codecs the service answered with.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Codec]
}

public extension CodecsEndpointProtocol {
    /// Fetches a list of all audio codecs.
    /// - Returns: An array of Codec objects.
    /// - Throws: An error if the request fails.
    func getAudioCodecs() async throws -> [any Codec] {
        try await fetch(.codecs, queryItems: [])
    }
}
