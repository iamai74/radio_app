import Foundation

/// Endpoint for interacting with languages.
final class LanguagesEndpoint: BaseEndpoint<LanguageObject>, LanguagesEndpointProtocol, @unchecked Sendable {
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Language] {
        try await fetch(endpoint: endpoint, queryItems: queryItems)
    }
}
