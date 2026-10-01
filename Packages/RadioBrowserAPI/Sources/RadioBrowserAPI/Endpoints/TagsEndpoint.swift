import Foundation

open class TagsEndpoint: TagsEndpointProtocol {
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
    
    public func getTags() async throws -> [Tag] {
        try await fetchTags(endpoint: .tags)
    }
    
    public func getTags(withFilter filter: String) async throws -> [Tag] {
        try await fetchTags(endpoint: .tagsByFilter, argument: filter)
    }
    
    private func fetchTags(endpoint: APIEndpoint, argument: String? = nil) async throws -> [Tag] {
        guard let url = urlBuilder.build(endpoint: endpoint, argument: argument) else {
            throw APIError.invalidURL
        }
        
        do {
            let data = try await networkClient.fetch(url: url)
            return try jsonDecoder.decode([TagObject].self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.networkFailed(error)
        }
    }
}