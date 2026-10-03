import Foundation

/// A protocol defining the interface for interacting with radio station endpoints.
public protocol StationsEndpointProtocol: Sendable {
    // swiftlint:disable function_parameter_count
    /// Fetches stations with the specified search parameters.
    /// - Parameters:
    ///   - country: Filter by country code (optional)
    ///   - language: Filter by language code (optional)
    ///   - tag: Filter by tag (optional)
    ///   - name: Filter by station name (optional)
    ///   - limit: Maximum number of stations to return (default 100)
    ///   - offset: Number of stations to skip (default 0)
    ///   - hideBreaks: Whether to exclude broken stations (default false)
    ///   - order: Sort order field (default "name")
    ///   - reverse: Whether to reverse the sort order (default false)
    /// - Returns: Array of Station objects matching the criteria
    /// - Throws: APIError if request fails
    func getStations(
        country: String?,
        language: String?,
        tag: String?,
        name: String?,
        limit: Int,
        offset: Int,
        hideBreaks: Bool,
        order: String,
        reverse: Bool
    ) async throws -> [any Station]
    // swiftlint:enable function_parameter_count

    /// Fetches a specific station by its ID.
    /// - Parameter id: The station's unique identifier
    /// - Returns: The station with the specified ID, or `nil` when the service knows no such station
    /// - Throws: APIError if request fails
    func getStation(byID id: String) async throws -> (any Station)?

    /// Searches for stations matching a query string.
    /// - Parameters:
    ///   - query: The search query
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of Station objects matching the query
    /// - Throws: APIError if request fails
    func searchStations(query: String, limit: Int) async throws -> [any Station]

    /// Fetches stations from a specific country.
    /// - Parameters:
    ///   - country: Country code filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects from the specified country
    /// - Throws: APIError if request fails
    func getStationsByCountry(_ country: String, limit: Int) async throws -> [any Station]

    /// Fetches stations in a specific language.
    /// - Parameters:
    ///   - language: Language code filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects in the specified language
    /// - Throws: APIError if request fails
    func getStationsByLanguage(_ language: String, limit: Int) async throws -> [any Station]

    /// Fetches stations with a specific tag.
    /// - Parameters:
    ///   - tag: Tag filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects with the specified tag
    /// - Throws: APIError if request fails
    func getStationsByTag(_ tag: String, limit: Int) async throws -> [any Station]

    /// Fetches all available stations.
    /// - Returns: Array of all Station objects
    /// - Throws: APIError if request fails
    func getAllStations() async throws -> [any Station]
}
