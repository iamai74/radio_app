import Foundation

/// Endpoint for interacting with audio codecs.
final class CodecsEndpoint: BaseEndpoint<CodecObject>, CodecsEndpointProtocol {
    public init(networkClient: NetworkClientProtocol) {
        super.init(networkClient: networkClient)
    }

    override init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder, jsonDecoder: JSONDecoderProtocol) {
        super.init(networkClient: networkClient, urlBuilder: urlBuilder, jsonDecoder: jsonDecoder)
    }

    /// Fetches a list of all audio codecs.
    /// - Returns: An array of Codec objects.
    /// - Throws: An error if the request fails.
    public func getAudioCodecs() async throws -> [any Codec] {
        try await fetch(endpoint: .codecs, exposing: { $0 })
    }
}
