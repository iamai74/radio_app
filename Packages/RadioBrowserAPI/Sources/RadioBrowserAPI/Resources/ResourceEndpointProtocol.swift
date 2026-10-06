import Foundation

/// An endpoint of the service that answers with a list of one resource kind.
///
/// Countries, languages, tags and codecs share the same shape — a plain list of a
/// counted resource — so they share one protocol with a primary associated type:
/// `any ResourceEndpointProtocol<Country>` is the country endpoint, and code written
/// against one resource works for every other resource unchanged.
public protocol ResourceEndpointProtocol<Resource>: Sendable {
    /// The resource the endpoint answers with, e.g. `Country` for the country endpoint.
    associatedtype Resource: Sendable

    /// Lists every resource the service knows about.
    /// - Returns: The full list, ordered as the service reports it.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func getResources() async throws -> [Resource]
}

/// An endpoint the service can additionally filter by a path segment.
///
/// Split from ``ResourceEndpointProtocol`` because the service does not offer the filter
/// for every resource: codecs have no filtered route, so the codec endpoint does not
/// pretend to have one.
public protocol ResourceFiltering<Resource>: ResourceEndpointProtocol {
    /// Lists the resources matching the filter, as the service interprets it.
    /// - Parameter filter: The filter, e.g. a language name; percent encoding is applied
    ///   by the package.
    /// - Returns: The matching resources.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func getResources(withFilter filter: String) async throws -> [Resource]
}
