import Foundation

/// A protocol defining the requirements for a network client.
public protocol NetworkClientProtocol: Sendable {
    /// Fetches data from the specified `URLRequest`.
    /// - Parameter request: The request to be performed.
    /// - Returns: The `Data` returned by the server.
    /// - Throws: An error if the request fails or the response is invalid.
    func fetch(request: URLRequest) async throws -> Data
}
