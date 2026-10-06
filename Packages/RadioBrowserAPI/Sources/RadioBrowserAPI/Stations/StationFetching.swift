import Foundation

/// Listing stations, filtered by criteria or walked page by page.
///
/// A consumer depending on this protocol declares that it browses the catalogue; it does
/// not get the lookup and search surface of ``StationSearching`` and ``StationLookup``
/// pushed onto it.
///
/// Criteria go through one value, ``StationQuery``: country, language and tag are query
/// items of a single request rather than a family of `getStationsByX` methods, so a new
/// criterion is a new property instead of a new protocol requirement — and a conformer
/// implements one method rather than one per filter.
public protocol StationFetching: Sendable {
    /// Fetches stations matching the given criteria.
    /// - Parameter query: The criteria, paging and ordering of the request.
    /// - Returns: The matching stations.
    /// - Throws: `APIError` if the request fails.
    func getStations(matching query: StationQuery) async throws -> [any Station]

    /// Fetches all radio stations.
    ///
    /// The request carries no query items at all — unlike ``getStations()``, which asks for
    /// the default page — which is why this is a requirement of its own.
    /// - Returns: Every station the service knows about.
    /// - Throws: `APIError` if the request fails.
    func getAllStations() async throws -> [any Station]
}

public extension StationFetching {
    /// Fetches stations with the default criteria.
    /// - Returns: The first page of stations, as ``StationQuery/default`` describes it.
    /// - Throws: `APIError` if the request fails.
    func getStations() async throws -> [any Station] {
        try await getStations(matching: StationQuery())
    }

    /// Walks a result set page by page instead of loading it in one request.
    ///
    /// Nothing is requested before the sequence is iterated, one request is in flight at a
    /// time, and stopping the iteration stops the walk — see ``StationPages``.
    ///
    /// - Parameters:
    ///   - query: The criteria of the whole walk; its `limit` and `offset` are replaced
    ///     per page, every other criterion is kept.
    ///   - pageSize: The number of stations requested per page.
    /// - Returns: A sequence yielding one page per request.
    func pages(
        matching query: StationQuery = .default,
        pageSize: Int = 100
    ) -> StationPages {
        StationPages(source: self, query: query, pageSize: pageSize)
    }
}
