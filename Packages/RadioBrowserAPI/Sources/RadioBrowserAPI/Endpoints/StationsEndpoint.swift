import Foundation

open class StationsEndpoint: StationsEndpointProtocol {
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
    
    public func getStations(
        country: String?,
        language: String?,
        tag: String?,
        name: String?,
        limit: Int,
        offset: Int,
        hideBroken: Bool,
        order: String,
        reverse: Bool
    ) async throws -> [Station] {
        var queryItems = [URLQueryItem]()
        
        if let country = country { queryItems.append(URLQueryItem(name: "country", value: country)) }
        if let language = language { queryItems.append(URLQueryItem(name: "language", value: language)) }
        if let tag = tag { queryItems.append(URLQueryItem(name: "tag", value: tag)) }
        if let name = name { queryItems.append(URLQueryItem(name: "name", value: name)) }
        
        queryItems.append(contentsOf: [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "hidebroken", value: hideBroken ? "true" : "false"),
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "reverse", value: reverse ? "true" : "false")
        ])
        
        return try await fetchObjects(endpoint: .stations, queryItems: queryItems)
    }
    
    public func getStation(byID id: String) async throws -> Station {
        try await fetchSingleObject(endpoint: .stationByID, argument: id)
    }
    
    public func searchStations(query: String, limit: Int) async throws -> [Station] {
        try await fetchObjects(
            endpoint: .stationsSearch,
            queryItems: [
                URLQueryItem(name: "name", value: query),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        )
    }
    
    public func getStationsByCountry(_ country: String, limit: Int) async throws -> [Station] {
        try await fetchObjects(
            endpoint: .stationsByCountry,
            argument: country,
            queryItems: [URLQueryItem(name: "limit", value: "\(limit)")]
        )
    }
    
    public func getStationsByLanguage(_ language: String, limit: Int) async throws -> [Station] {
        try await fetchObjects(
            endpoint: .stationsByLanguage,
            argument: language,
            queryItems: [URLQueryItem(name: "limit", value: "\(limit)")]
        )
    }
    
    public func getStationsByTag(_ tag: String, limit: Int) async throws -> [Station] {
        try await fetchObjects(
            endpoint: .stationsByTag,
            argument: tag,
            queryItems: [URLQueryItem(name: "limit", value: "\(limit)")]
        )
    }
    
    public func getAllStations() async throws -> [Station] {
        try await fetchObjects(endpoint: .stations)
    }
    
    private func fetchObjects(endpoint: APIEndpoint, argument: String? = nil, queryItems: [URLQueryItem] = []) async throws -> [Station] {
        guard let url = urlBuilder.build(endpoint: endpoint, argument: argument, queryItems: queryItems) else {
            throw APIError.invalidURL
        }
        
        do {
            let data = try await networkClient.fetch(url: url)
            return try jsonDecoder.decode([StationObject].self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.networkFailed(error)
        }
    }
    
    private func fetchSingleObject(endpoint: APIEndpoint, argument: String) async throws -> Station {
        guard let url = urlBuilder.build(endpoint: endpoint, argument: argument) else {
            throw APIError.invalidURL
        }
        
        do {
            let data = try await networkClient.fetch(url: url)
            return try jsonDecoder.decode(StationObject.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.networkFailed(error)
        }
    }
}