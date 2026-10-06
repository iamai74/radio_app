import Foundation

/// The primitive every station capability is built on: perform a route and decode the
/// answer into stations.
///
/// Everything ``StationFetching``, ``StationSearching`` and ``StationLookup`` offer is a
/// default implementation on top of this single requirement, so a type conforming to
/// ``StationsEndpointProtocol`` — a mock, or an alternative implementation — implements
/// one method instead of nine.
public protocol StationRequesting: Sendable {
    /// Performs a route of the service and returns the decoded stations.
    /// - Parameters:
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The stations the service answered with.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Station]
}
