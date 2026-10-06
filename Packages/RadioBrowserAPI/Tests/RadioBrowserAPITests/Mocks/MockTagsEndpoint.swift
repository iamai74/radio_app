import Foundation
import RadioBrowserAPI

/// Mock implementation of TagsEndpointProtocol for testing purposes.
final class MockTagsEndpoint: TagsEndpointProtocol {
    private let tags: [Tag]
    private let error: Error?
    
    /// Initializes the mock tags endpoint with specific data and potential error.
    /// - Parameters:
    ///   - tags: The tags to return from fetch operations, or empty array if no tags.
    ///   - error: The error to throw from fetch operations, or nil if no error.
    init(tags: [Tag] = [], error: Error? = nil) {
        self.tags = tags
        self.error = error
    }

    /// Answers every route with the fixture this mock was built with.
    /// - Parameters:
    ///   - endpoint: The route that was requested; the mock answers all of them alike.
    ///   - queryItems: The query items of the request, ignored by the mock.
    /// - Returns: The tags this mock was built with.
    /// - Throws: The configured error, if any.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Tag] {
        if let error {
            throw error
        }

        return tags
    }
}
