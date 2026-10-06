import Foundation

/// Endpoint for interacting with audio codecs.
final class CodecsEndpoint: BaseEndpoint<CodecObject>, CodecsEndpointProtocol, @unchecked Sendable {
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Codec] {
        try await fetch(endpoint: endpoint, queryItems: queryItems)
    }
}
