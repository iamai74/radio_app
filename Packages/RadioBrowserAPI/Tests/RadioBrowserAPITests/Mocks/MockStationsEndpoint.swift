import Foundation
import RadioBrowserAPI

/// Mock implementation of StationsEndpointProtocol for testing purposes.
///
/// With the route-executing primitive gone from the public surface, the double implements
/// the capability methods its callers use; they all answer from the same fixture, the
/// shared `result()` keeps the repetition down to one line per method.
final class MockStationsEndpoint: StationsEndpointProtocol {
    private let stations: [Station]
    private let error: Error?

    /// Initializes the mock stations endpoint with specific data and potential error.
    /// - Parameters:
    ///   - stations: The stations to return from list operations, or empty array if no stations.
    ///   - error: The error to throw from list operations, or nil if no error.
    init(stations: [Station] = [], error: Error? = nil) {
        self.stations = stations
        self.error = error
    }

    func getStations(matching _: StationQuery) async throws -> [any Station] {
        try result()
    }

    func getAllStations() async throws -> [any Station] {
        try result()
    }

    func getStationsByCountry(_: String, limit _: Int) async throws -> [any Station] {
        try result()
    }

    func getStationsByLanguage(_: String, limit _: Int) async throws -> [any Station] {
        try result()
    }

    func getStationsByTag(_: String, limit _: Int) async throws -> [any Station] {
        try result()
    }

    func searchStations(query _: String, limit _: Int) async throws -> [any Station] {
        try result()
    }

    /// Looks the station up in the fixture instead of relying on the list convention the
    /// service uses, so a double can answer from its own data.
    /// - Parameter id: The station's unique identifier.
    /// - Returns: The matching station, or `nil` when the fixture holds no such station.
    /// - Throws: The configured error, if any.
    func getStation(byID id: String) async throws -> (any Station)? {
        if let error {
            throw error
        }

        return stations.first { $0.id == id }
    }

    private func result() throws -> [any Station] {
        if let error {
            throw error
        }

        return stations
    }
}
