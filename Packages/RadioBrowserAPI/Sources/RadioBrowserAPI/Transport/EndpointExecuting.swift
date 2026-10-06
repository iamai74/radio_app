import Foundation

/// Executes the routes of the service: the request pipeline every endpoint shares.
///
/// The package's open extension point: a route it does not know about yet can be built as a
/// value conforming to ``EndpointDefinition`` and run through the executor of a client —
/// mirror failover, request policy and decoding included — without changing the package.
public protocol EndpointExecuting: Sendable {
    /// Fetches and decodes a list of models from the given endpoint.
    /// - Parameters:
    ///   - type: The payload model the service answers with.
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: Decoded models of type `Model`.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding, transport and cancellation
    ///   failures.
    func fetch<Model: Decodable>(
        _ type: Model.Type,
        endpoint: any EndpointDefinition,
        queryItems: [URLQueryItem]
    ) async throws -> [Model]
}
