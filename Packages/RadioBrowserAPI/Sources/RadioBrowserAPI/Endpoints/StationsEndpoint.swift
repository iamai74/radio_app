import Foundation

/// Endpoint for interacting with radio stations.
final class StationsEndpoint: BaseEndpoint<StationObject>, StationsEndpointProtocol, @unchecked Sendable {
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Station] {
        try await fetch(endpoint: endpoint, queryItems: queryItems)
    }

    func getStation(byID id: String) async throws -> (any Station)? {
        try await fetchFirst(endpoint: APIEndpoint.stationByID(id: id))
    }
}
