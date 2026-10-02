import Foundation

open class CodecsEndpoint: CodecsEndpointProtocol {
    private let networkClient: NetworkClientProtocol
    private let urlBuilder: URLBuilder
    private let jsonDecoder: JSONDecoderProtocol

    public init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
        self.urlBuilder = URLBuilder()
        self.jsonDecoder = DefaultJSONDecoder()
    }

    init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder, jsonDecoder: JSONDecoderProtocol) {
        self.networkClient = networkClient
        self.urlBuilder = urlBuilder
        self.jsonDecoder = jsonDecoder
    }

    public func getAudioCodecs() async throws -> [Codec] {
        guard let url = urlBuilder.build(endpoint: .codecs) else {
            throw APIError.invalidURL
        }

        do {
            let data = try await networkClient.fetch(url: url)
            return try jsonDecoder.decode([CodecObject].self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.networkFailed(error)
        }
    }
}
