import Foundation

/// Runs the routes of the service and decodes the answers.
///
/// The executor owns the whole request pipeline of an endpoint — building the request,
/// walking the mirrors, decoding — so the endpoints themselves only name a route and a
/// payload type. Every stored value is immutable, which makes the executor `Sendable`
/// without annotation: one instance is built per client and shared by all its endpoints.
internal struct RequestExecutor: Sendable {
    private let networkClient: NetworkClientProtocol
    private let requestBuilders: [RequestBuilder]
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
        self.networkClient = networkClient
        self.requestBuilders = configuration.baseURLs.map { RequestBuilder(mirror: $0, configuration: configuration) }
        self.jsonDecoder = jsonDecoder
    }

    /// Fetches and decodes a list of models from the given endpoint.
    /// - Parameters:
    ///   - type: The payload model the service answers with — the package's decode types,
    ///     not the read models the callers consume.
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: Decoded models of type `Model`.
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    @discardableResult
    func fetch<Model: Decodable>(
        _ type: Model.Type,
        endpoint: any EndpointDefinition,
        queryItems: [URLQueryItem] = []
    ) async throws -> [Model] {
        let data = try await fetchData(endpoint: endpoint, queryItems: queryItems)

        do {
            return try jsonDecoder.decode([Model].self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.undetermined(error)
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
    /// - Throws: `APIError` for invalid URL, HTTP, decoding and network failures.
    func fetchFirst<Model: Decodable>(
        _ type: Model.Type,
        endpoint: any EndpointDefinition,
        queryItems: [URLQueryItem] = []
    ) async throws -> Model? {
        try await fetch(type, endpoint: endpoint, queryItems: queryItems).first
    }

    /// Performs the request against the first mirror that accepts it.
    ///
    /// A mirror is skipped while the failure it reported is retryable, so an unreachable or
    /// briefly failing server costs one attempt instead of the whole call.
    private func fetchData(endpoint: any EndpointDefinition, queryItems: [URLQueryItem]) async throws -> Data {
        var lastFailure: APIError = .invalidURL

        for (index, requestBuilder) in requestBuilders.enumerated() {
            let isLastMirror = index == requestBuilders.count - 1

            guard let request = requestBuilder.request(for: endpoint, queryItems: queryItems) else {
                lastFailure = .invalidURL

                if isLastMirror {
                    break
                }

                continue
            }

            do {
                return try await networkClient.fetch(request: request)
            } catch let error as CancellationError {
                throw error
            } catch {
                let failure = error as? APIError ?? APIError.networkFailed(error)
                lastFailure = failure

                if isLastMirror || !failure.isRetryable {
                    throw failure
                }
            }
        }

        throw lastFailure
    }
}
