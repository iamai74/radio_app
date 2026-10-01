import Foundation

open class CountriesEndpoint: CountriesEndpointProtocol {
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
    
    public func getCountries() async throws -> [Country] {
        try await fetchCountries(endpoint: .countries)
    }
    
    public func getCountries(withFilter filter: String) async throws -> [Country] {
        try await fetchCountries(endpoint: .countriesByFilter, argument: filter)
    }
    
    private func fetchCountries(endpoint: APIEndpoint, argument: String? = nil) async throws -> [Country] {
        guard let url = urlBuilder.build(endpoint: endpoint, argument: argument) else {
            throw APIError.invalidURL
        }
        
        do {
            let data = try await networkClient.fetch(url: url)
            return try jsonDecoder.decode([CountryObject].self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.networkFailed(error)
        }
    }
}