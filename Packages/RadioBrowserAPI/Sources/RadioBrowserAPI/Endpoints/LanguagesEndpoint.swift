import Foundation

open class LanguagesEndpoint: LanguagesEndpointProtocol {
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

    public func getLanguages() async throws -> [Language] {
        try await fetchLanguages(endpoint: .languages)
    }

    public func getLanguages(withFilter filter: String) async throws -> [Language] {
        try await fetchLanguages(endpoint: .languagesByFilter, argument: filter)
    }

    private func fetchLanguages(endpoint: APIEndpoint, argument: String? = nil) async throws -> [Language] {
        guard let url = urlBuilder.build(endpoint: endpoint, argument: argument) else {
            throw APIError.invalidURL
        }

        do {
            let data = try await networkClient.fetch(url: url)
            return try jsonDecoder.decode([LanguageObject].self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.networkFailed(error)
        }
    }
}
