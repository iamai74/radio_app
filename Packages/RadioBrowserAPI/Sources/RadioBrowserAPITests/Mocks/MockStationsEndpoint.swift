import Foundation
import RadioBrowserAPI

/// Mock implementation of StationsEndpointProtocol for testing purposes.
final class MockStationsEndpoint: StationsEndpointProtocol {
    private let stations: [Station]
    private let error: Error?
    
    /// Initializes the mock stations endpoint with specific data and potential error.
    /// - Parameters:
    ///   - stations: The stations to return from fetch operations, or empty array if no stations.
    ///   - error: The error to throw from fetch operations, or nil if no error.
    init(stations: [Station] = [], error: Error? = nil) {
        self.stations = stations
        self.error = error
    }
    
    // swiftlint:disable function_parameter_count
    /// Fetches a list of radio stations based on the given criteria.
    /// - Parameters:
    ///   - country: The country to filter by, or nil for all countries.
    ///   - language: The language to filter by, or nil for all languages.
    ///   - tag: The tag to filter by, or nil for all tags.
    ///   - name: The name to filter by, or nil for all names.
    ///   - limit: The maximum number of results to return.
    ///   - offset: The offset to start retrieving results from.
    ///   - hideBreaks: Whether to hide breaks in the results.
    ///   - order: The field to order by.
    ///   - reverse: Whether the results should be in reverse order.
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
    ) async throws -> [any Station] {
        if let error = error {
            throw error
        }
        return stations
    }
    // swiftlint:enable function_parameter_count
    
    /// Fetches all radio stations.
    /// - Returns: Array of Station objects
    /// - Throws: APIError if request fails
    func getAllStations() async throws -> [any Station] {
        if let error = error {
            throw error
        }
        return stations
    }
    
    /// Fetches a specific station by its ID.
    /// - Parameter id: The station's unique identifier
    /// - Returns: The station with the specified ID, or `nil` when the double knows no such station
    /// - Throws: The configured error, if any.
    func getStation(byID id: String) async throws -> (any Station)? {
        if let error = error {
            throw error
        }

        return stations.first(where: { $0.id == id })
    }
    
    /// Searches for stations matching a query string.
    /// - Parameters:
    ///   - query: The search query
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of Station objects matching the query
    /// - Throws: APIError if request fails
    func searchStations(query: String, limit: Int) async throws -> [any Station] {
        if let error = error {
            throw error
        }
        return stations
    }
    
    /// Fetches stations from a specific country.
    /// - Parameters:
    ///   - country: Country code filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects from the specified country
    /// - Throws: APIError if request fails
    func getStationsByCountry(_ country: String, limit: Int) async throws -> [any Station] {
        if let error = error {
            throw error
        }
        return stations
    }
    
    /// Fetches stations in a specific language.
    /// - Parameters:
    ///   - language: Language code filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects in the specified language
    /// - Throws: APIError if request fails
    func getStationsByLanguage(_ language: String, limit: Int) async throws -> [any Station] {
        if let error = error {
            throw error
        }
        return stations
    }
    
    /// Fetches stations with a specific tag.
    /// - Parameters:
    ///   - tag: Tag filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects with the specified tag
    /// - Throws: APIError if request fails
    func getStationsByTag(_ tag: String, limit: Int) async throws -> [any Station] {
        if let error = error {
            throw error
        }
        return stations
    }
}
