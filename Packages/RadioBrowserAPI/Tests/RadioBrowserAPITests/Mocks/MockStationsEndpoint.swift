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

    /// Answers every route with the fixture this mock was built with.
    /// - Parameters:
    ///   - endpoint: The route that was requested; the mock answers all of them alike.
    ///   - queryItems: The query items of the request, ignored by the mock.
    /// - Returns: The stations this mock was built with.
    /// - Throws: The configured error, if any.
    func fetch(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]) async throws -> [any Station] {
        if let error {
            throw error
        }

        return stations
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
}
