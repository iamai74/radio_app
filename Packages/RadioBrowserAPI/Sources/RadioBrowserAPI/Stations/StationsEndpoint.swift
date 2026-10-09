import Foundation

/// Endpoint for interacting with radio stations.
///
/// A value type: it names the routes and the payload, everything else — request building,
/// mirror failover, decoding — belongs to the shared ``RequestExecutor``.
internal struct StationsEndpoint: StationsEndpointProtocol {
    private let executor: RequestExecutor

    /// - Parameter executor: The request pipeline shared with the other endpoints of a client.
    init(executor: RequestExecutor) {
        self.executor = executor
    }

    /// An endpoint with its own transport and mirrors.
    /// - Parameters:
    ///   - networkClient: The transport performing the requests.
    ///   - configuration: The mirrors and request policy of every attempt.
    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default
    ) {
        self.init(executor: RequestExecutor(networkClient: networkClient, configuration: configuration))
    }

    func getStations(matching query: StationQuery) async throws -> [any Station] {
        try await executor.fetch(StationObject.self, endpoint: APIEndpoint.stations, queryItems: query.queryItems)
    }

    func getAllStations() async throws -> [any Station] {
        try await executor.fetch(StationObject.self, endpoint: APIEndpoint.stations)
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
