import Foundation

/// Looking up a single station.
///
/// The method is a requirement rather than a default implementation: Radio Browser has no
/// single object route, so the answer is the first element of a list, and a test double
/// holding a handful of stations can answer the lookup from its own fixtures instead of
/// relying on that convention.
public protocol StationLookup: StationRequesting {
    /// Fetches a specific station by its ID.
    ///
    /// Radio Browser exposes no single station route, so the request goes to
    /// `/json/stations/byuuid/{id}`, which answers with a list.
    /// - Parameter id: The station's unique identifier.
    /// - Returns: The station with the specified ID, or `nil` when the service knows no
    ///   such station.
    /// - Throws: `APIError` if the request fails.
    func getStation(byID id: String) async throws -> (any Station)?
}
