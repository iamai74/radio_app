import Foundation
import RadioBrowserAPI

/// Mock implementation of CodecsEndpointProtocol for testing purposes.
final class MockCodecsEndpoint: CodecsEndpointProtocol {
    private let codecs: [Codec]
    private let error: Error?
    
    /// Initializes the mock codecs endpoint with specific data and potential error.
    /// - Parameters:
    ///   - codecs: The codecs to return from fetch operations, or empty array if no codecs.
    ///   - error: The error to throw from fetch operations, or nil if no error.
    init(codecs: [Codec] = [], error: Error? = nil) {
        self.codecs = codecs
        self.error = error
    }

    /// Answers every route with the fixture this mock was built with.
    /// - Parameters:
    ///   - endpoint: The route that was requested; the mock answers all of them alike.
    ///   - queryItems: The query items of the request, ignored by the mock.
    /// - Returns: The codecs this mock was built with.
    /// - Throws: The configured error, if any.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Codec] {
        if let error {
            throw error
        }

        return codecs
    }
}
