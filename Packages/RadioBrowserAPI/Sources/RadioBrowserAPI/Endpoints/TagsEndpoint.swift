import Foundation

/// Endpoint for interacting with tags.
final class TagsEndpoint: BaseEndpoint<TagObject>, TagsEndpointProtocol, @unchecked Sendable {
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Tag] {
        try await fetch(endpoint: endpoint, queryItems: queryItems)
    }
}
