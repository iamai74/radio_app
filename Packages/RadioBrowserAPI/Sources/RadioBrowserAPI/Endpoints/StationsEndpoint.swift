import Foundation

/// Endpoint for interacting with radio stations.
///
/// A value type: it names the routes and the payload, everything else — request building,
/// mirror failover, decoding — belongs to the shared ``RequestExecutor``.
internal struct StationsEndpoint: StationsEndpointProtocol {
    private let executor: RequestExecutor

    /// - Parameters:
    ///   - networkClient: The transport performing the requests.
    ///   - configuration: The mirrors and request policy to use.
    ///   - jsonDecoder: The decoder turning responses into stations.
    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.executor = RequestExecutor(
            networkClient: networkClient,
            configuration: configuration,
            jsonDecoder: jsonDecoder
        )
    }

    /// - Parameter executor: The request pipeline shared with the other endpoints of a client.
    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getStations(matching query: StationQuery) async throws -> [any Station] {
        try await executor.fetch(StationObject.self, endpoint: APIEndpoint.stations, queryItems: query.queryItems)
    }

    func getAllStations() async throws -> [any Station] {
        try await executor.fetch(StationObject.self, endpoint: APIEndpoint.stations)
    }

    func getStationsByCountry(_ country: String, limit: Int) async throws -> [any Station] {
        try await executor.fetch(
            StationObject.self,
            endpoint: APIEndpoint.stationsByCountry(countryCode: country),
            queryItems: QueryItems.limit(limit)
        )
    }

    func getStationsByLanguage(_ language: String, limit: Int) async throws -> [any Station] {
        try await executor.fetch(
            StationObject.self,
            endpoint: APIEndpoint.stationsByLanguage(languageCode: language),
            queryItems: QueryItems.limit(limit)
        )
    }

    func getStationsByTag(_ tag: String, limit: Int) async throws -> [any Station] {
        try await executor.fetch(
            StationObject.self,
            endpoint: APIEndpoint.stationsByTag(tag: tag),
            queryItems: QueryItems.limit(limit)
        )
    }

    func searchStations(query: String, limit: Int) async throws -> [any Station] {
        try await executor.fetch(
            StationObject.self,
            endpoint: APIEndpoint.stationsSearch(query: query),
            queryItems: QueryItems.limit(limit)
        )
    }

    func getStation(byID id: String) async throws -> (any Station)? {
        try await executor.fetchFirst(StationObject.self, endpoint: APIEndpoint.stationByID(id: id))
    }
}
