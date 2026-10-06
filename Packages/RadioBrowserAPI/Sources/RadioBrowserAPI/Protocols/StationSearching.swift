import Foundation

/// Searching stations by free text.
public protocol StationSearching: StationRequesting {}

public extension StationSearching {
    /// Searches for stations matching a query string.
    /// - Parameters:
    ///   - query: The search query.
    ///   - limit: Maximum number of results to return, `0` for no limit.
    /// - Returns: The stations matching the query.
    /// - Throws: `APIError` if the request fails.
    func searchStations(query: String, limit: Int) async throws -> [any Station] {
        try await fetch(.stationsSearch(query: query), queryItems: QueryItems.limit(limit))
    }
}
