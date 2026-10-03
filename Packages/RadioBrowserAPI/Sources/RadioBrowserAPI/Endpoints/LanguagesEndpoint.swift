import Foundation

/// Endpoint for interacting with languages.
public final class LanguagesEndpoint: BaseEndpoint<LanguageObject>, LanguagesEndpointProtocol {
    public init(networkClient: NetworkClientProtocol) {
        super.init(networkClient: networkClient)
    }

    override init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder, jsonDecoder: JSONDecoderProtocol) {
        super.init(networkClient: networkClient, urlBuilder: urlBuilder, jsonDecoder: jsonDecoder)
    }

    /// Fetches a list of all languages.
    /// - Returns: An array of Language objects.
    /// - Throws: An error if the request fails.
    public func getLanguages() async throws -> [any Language] {
        try await fetch(endpoint: .languages, exposing: { $0 })
    }

    /// Fetches a list of languages that match the given filter.
    /// - Parameter filter: The filter to apply to the results.
    /// - Returns: An array of Language objects matching the filter.
    /// - Throws: An error if the request fails.
    public func getLanguages(withFilter filter: String) async throws -> [any Language] {
        try await fetch(endpoint: .languagesByFilter(filter: filter), exposing: { $0 })
    }
}
