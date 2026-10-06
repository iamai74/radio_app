import Foundation

/// Endpoint for interacting with radio stations.
///
/// A value type: it names the routes and the payload, everything else — request building,
/// mirror failover, decoding — belongs to the shared ``RequestExecutor``.
internal struct StationsEndpoint: StationsEndpointProtocol, EndpointInitializing {
    private let executor: RequestExecutor

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
