import Foundation

/// A resource of the service that is identified by a name and counted in stations.
///
/// Countries, languages, tags and codecs share this shape, so code that works for one of
/// them — a list row, an adapter, a sort — works for all of them through this protocol.
public protocol StationCounted: Sendable {
    /// The name of the resource, as reported by the API.
    var name: String { get }

    /// The number of stations this resource accounts for.
    var stationCount: Int { get }
}
