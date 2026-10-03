import Foundation

/// Endpoint for interacting with tags.
final class TagsEndpoint: BaseEndpoint<TagObject>, TagsEndpointProtocol {
    public init(networkClient: NetworkClientProtocol) {
        super.init(networkClient: networkClient)
    }

    override init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder, jsonDecoder: JSONDecoderProtocol) {
        super.init(networkClient: networkClient, urlBuilder: urlBuilder, jsonDecoder: jsonDecoder)
    }

    /// Fetches a list of all tags.
    /// - Returns: An array of Tag objects.
    /// - Throws: An error if the request fails.
    public func getTags() async throws -> [any Tag] {
        try await fetch(endpoint: .tags, exposing: { $0 })
    }

    /// Fetches a list of tags that match the given filter.
    /// - Parameter filter: The filter to apply to the results.
    /// - Returns: An array of Tag objects matching the filter.
    /// - Throws: An error if the request fails.
    public func getTags(withFilter filter: String) async throws -> [any Tag] {
        try await fetch(endpoint: .tagsByFilter(filter: filter), exposing: { $0 })
    }
}
