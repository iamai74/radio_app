import Foundation

/// Base class for endpoint implementations that handles common API communication logic.
///
/// The class is generic over the concrete `Model` used for decoding, which keeps the
/// decoding implementation details (e.g. `StationObject`) inside the package while
/// subclasses expose the model protocols their callers consume.
///
/// Every request walks the mirrors of the ``RadioBrowserConfiguration`` in order and only
/// gives up on the first failure that is not retryable.
internal class BaseEndpoint<Model: Decodable>: @unchecked Sendable {
    private let networkClient: NetworkClientProtocol
    private let urlBuilders: [URLBuilder]
    private let jsonDecoder: JSONDecoderProtocol
    private let timeout: TimeInterval
    private let cachePolicy: URLRequest.CachePolicy

    /// Initializes the endpoint with its collaborators.
    /// - Parameters:
    ///   - networkClient: The client performing the HTTP requests.
    ///   - configuration: The service mirrors and request policy to use.
    ///   - jsonDecoder: The decoder turning the response into models.
    internal init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.networkClient = networkClient
        self.urlBuilders = configuration.baseURLs.map { URLBuilder(baseURL: $0) }
        self.jsonDecoder = jsonDecoder
        self.timeout = configuration.timeout
        self.cachePolicy = configuration.cachePolicy
    }

    /// Fetches and decodes a list of models from the given endpoint.
    /// - Parameters:
    ///   - endpoint: The API endpoint to fetch data from.
    ///   - queryItems: Optional query parameters appended to the endpoint's own ones.
    /// - Returns: Decoded models of type `Model`.
    /// - Throws: `APIError` for invalid URL, decoding failures and network failures.
    @discardableResult
    func fetch(endpoint: any EndpointDefinition, queryItems: [URLQueryItem] = []) async throws -> [Model] {
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
    ///   - endpoint: The API endpoint to fetch data from.
    ///   - queryItems: Optional query parameters appended to the endpoint's own ones.
    /// - Returns: The first decoded model, or `nil` when the service answered with an empty list.
    /// - Throws: `APIError` for invalid URL, decoding failures and network failures.
    func fetchFirst(endpoint: any EndpointDefinition, queryItems: [URLQueryItem] = []) async throws -> Model? {
        try await fetch(endpoint: endpoint, queryItems: queryItems).first
    }

    /// Performs the request against the first mirror that accepts it.
    ///
    /// A mirror is skipped while the failure it reported is retryable, so an unreachable or
    /// briefly failing server costs one attempt instead of the whole call.
    private func fetchData(endpoint: any EndpointDefinition, queryItems: [URLQueryItem]) async throws -> Data {
        var lastFailure: APIError = .invalidURL

        for (index, urlBuilder) in urlBuilders.enumerated() {
            let isLastMirror = index == urlBuilders.count - 1

            guard let url = urlBuilder.build(endpoint: endpoint, queryItems: queryItems) else {
                lastFailure = .invalidURL

                if isLastMirror {
                    break
                }

                continue
            }

            var request = URLRequest(url: url)
            request.timeoutInterval = timeout
            request.cachePolicy = cachePolicy

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
