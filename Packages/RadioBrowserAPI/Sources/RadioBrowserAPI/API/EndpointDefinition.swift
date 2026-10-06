import Foundation

/// A route of the Radio Browser service: where to send the request and with which query.
///
/// The package ships the routes it needs as ``APIEndpoint``, but the type is open: any
/// value conforming to this protocol is accepted by ``URLBuilding`` and by the package's
/// request pipeline, so a service route that the package does not know about yet can be
/// added by extending it — without touching the URL building or the failover logic.
public protocol EndpointDefinition: Sendable {
    /// The API path, starting with a slash, e.g. `/json/stations`.
    var path: String { get }

    /// The query items the route requires, e.g. `q` for a search.
    var queryItems: [URLQueryItem] { get }
}

public extension EndpointDefinition {
    var queryItems: [URLQueryItem] {
        []
    }
}
