import Foundation

/// Listing stations, filtered by criteria or walked page by page.
///
/// A consumer depending on this protocol declares that it browses the catalogue; it does
/// not get the lookup and search surface of ``StationSearching`` and ``StationLookup``
/// pushed onto it.
public protocol StationFetching: StationRequesting {}

public extension StationFetching {
    /// Fetches stations with the default criteria.
    /// - Returns: The first page of stations, as ``StationQuery/default`` describes it.
    /// - Throws: `APIError` if the request fails.
    func getStations() async throws -> [any Station] {
        try await getStations(matching: StationQuery())
    }

    /// Fetches stations matching the given criteria.
    /// - Parameter query: The criteria, paging and ordering of the request.
    /// - Returns: The matching stations.
    /// - Throws: `APIError` if the request fails.
    func getStations(matching query: StationQuery) async throws -> [any Station] {
        try await fetch(.stations, queryItems: query.queryItems)
    }

    /// Fetches all radio stations.
    /// - Returns: Every station the service knows about.
    /// - Throws: `APIError` if the request fails.
    func getAllStations() async throws -> [any Station] {
        try await fetch(.stations, queryItems: [])
    }

    /// Fetches stations from a specific country.
    /// - Parameters:
    ///   - country: Country code filter.
    ///   - limit: Maximum number of stations to return, `0` for no limit.
    /// - Returns: The stations of the country.
    /// - Throws: `APIError` if the request fails.
    func getStationsByCountry(_ country: String, limit: Int) async throws -> [any Station] {
        try await fetch(.stationsByCountry(countryCode: country), queryItems: QueryItems.limit(limit))
    }

    /// Fetches stations in a specific language.
    /// - Parameters:
    ///   - language: Language code filter.
    ///   - limit: Maximum number of stations to return, `0` for no limit.
    /// - Returns: The stations of the language.
    /// - Throws: `APIError` if the request fails.
    func getStationsByLanguage(_ language: String, limit: Int) async throws -> [any Station] {
        try await fetch(.stationsByLanguage(languageCode: language), queryItems: QueryItems.limit(limit))
    }

    /// Fetches stations with a specific tag.
    /// - Parameters:
    ///   - tag: Tag filter.
    ///   - limit: Maximum number of stations to return, `0` for no limit.
    /// - Returns: The stations carrying the tag.
    /// - Throws: `APIError` if the request fails.
    func getStationsByTag(_ tag: String, limit: Int) async throws -> [any Station] {
        try await fetch(.stationsByTag(tag: tag), queryItems: QueryItems.limit(limit))
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
