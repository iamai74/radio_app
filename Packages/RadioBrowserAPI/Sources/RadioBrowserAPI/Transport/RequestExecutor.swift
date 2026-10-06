import Foundation

/// Runs the routes of the service and decodes the answers.
///
/// The executor owns the request pipeline of an endpoint — asking ``FailoverTransport``
/// for the payload, decoding it — so the endpoints themselves only name a route and a
/// payload type. Every stored value is immutable, which makes the executor `Sendable`
/// without annotation: one instance is built per client and shared by all its endpoints.
internal struct RequestExecutor: EndpointExecuting, Sendable {
    private let transport: FailoverTransport
    private let jsonDecoder: JSONDecoderProtocol

    /// - Parameters:
    ///   - networkClient: The transport performing the requests.
    ///   - configuration: The mirrors and request policy of every attempt.
    ///   - jsonDecoder: The decoder turning responses into models.
    internal init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.transport = FailoverTransport(networkClient: networkClient, configuration: configuration)
        self.jsonDecoder = jsonDecoder
    }

    /// Fetches and decodes a list of models from the given endpoint.
    /// - Parameters:
    ///   - type: The payload model the service answers with — the package's decode types,
    ///     not the read models the callers consume.
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: Decoded models of type `Model`.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding, transport and cancellation
    ///   failures.
    @discardableResult
    func fetch<Model: Decodable>(
        _ type: Model.Type,
        endpoint: any EndpointDefinition,
        queryItems: [URLQueryItem] = []
    ) async throws -> [Model] {
        let data = try await transport.fetchData(for: endpoint, queryItems: queryItems)

        do {
            return try jsonDecoder.decode([Model].self, from: data)
        } catch {
            throw APIError.fromPayload(error)
        }
    }

    /// Fetches the first object of an endpoint that answers with a list.
    ///
    /// Radio Browser has no single object route: `/json/stations/byuuid/{id}` returns a list
    /// holding the requested station, and an empty list when the station is unknown.
    /// - Parameters:
    ///   - type: The payload model the service answers with.
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The first decoded model, or `nil` when the service answered with an empty list.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding, transport and cancellation
    ///   failures.
    func fetchFirst<Model: Decodable>(
        _ type: Model.Type,
        endpoint: any EndpointDefinition,
        queryItems: [URLQueryItem] = []
    ) async throws -> Model? {
        try await fetch(type, endpoint: endpoint, queryItems: queryItems).first
    }
}
