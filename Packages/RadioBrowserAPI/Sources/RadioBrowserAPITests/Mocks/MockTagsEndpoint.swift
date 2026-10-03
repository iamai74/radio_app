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
    
    /// Fetches a list of all tags.
    /// - Returns: Array of Tag objects representing all tags.
    /// - Throws: APIError if request fails.
    func getTags() async throws -> [any Tag] {
        if let error = error {
            throw error
        }
        return tags
    }
    
    /// Fetches tags with the given filter.
    /// - Parameter filter: The filter to apply (e.g. by name or code)
    /// - Returns: Array of Tag objects matching the filter
    /// - Throws: APIError if request fails
    func getTags(withFilter filter: String) async throws -> [any Tag] {
        if let error = error {
            throw error
        }
        return tags
    }
}
