import Foundation

/// Base class for endpoint implementations that handles common API communication logic.
///
/// The class is generic over the concrete `Model` used for decoding, which keeps the
/// decoding implementation details (e.g. `StationObject`) inside the package while
/// subclasses may still expose either of the two flavours to their callers:
/// - concrete structs via `fetch(endpoint:queryItems:)`;
/// - model protocols via `fetch(endpoint:queryItems:exposing:)`, which erases the
///   decoded structs into the protocol abstraction the client consumes.
internal class BaseEndpoint<Model: Decodable> {
    let networkClient: NetworkClientProtocol
    let urlBuilder: URLBuilder
    let jsonDecoder: JSONDecoderProtocol

    /// Initializes the endpoint with its collaborators.
    /// - Parameters:
    ///   - networkClient: The client performing the HTTP requests.
    ///   - urlBuilder: The builder turning an endpoint into a `URL`.
    ///   - jsonDecoder: The decoder turning the response into models.
    internal init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder = URLBuilder(), jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()) {
        self.networkClient = networkClient
        self.urlBuilder = urlBuilder
        self.jsonDecoder = jsonDecoder
    }

    /// Fetches and decodes a list of concrete models from the given endpoint.
    /// - Parameters:
    ///   - endpoint: The API endpoint to fetch data from.
    ///   - queryItems: Optional query parameters appended to the endpoint's own ones.
    /// - Returns: Decoded concrete models of type `Model`.
    /// - Throws: `APIError` for invalid URL, decoding failures and network failures.
    @discardableResult
    func fetch(endpoint: APIEndpoint, queryItems: [URLQueryItem] = []) async throws -> [Model] {
        try await fetchData(endpoint: endpoint, queryItems: queryItems, decode: { try self.jsonDecoder.decode([Model].self, from: $0) })
    }

    /// Fetches and decodes a list of concrete models and erases them into the model protocol.
    /// - Parameters:
    ///   - endpoint: The API endpoint to fetch data from.
    ///   - queryItems: Optional query parameters appended to the endpoint's own ones.
    ///   - exposing: Converts a decoded concrete model into the protocol returned to the client.
    /// - Returns: Decoded models converted to the protocol abstraction.
    /// - Throws: `APIError` for invalid URL, decoding failures and network failures.
    @discardableResult
    func fetch<Output>(
        endpoint: APIEndpoint,
        queryItems: [URLQueryItem] = [],
        exposing transform: (Model) throws -> Output
    ) async throws -> [Output] {
        try await fetch(endpoint: endpoint, queryItems: queryItems).map(transform)
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
    func fetchFirst(endpoint: APIEndpoint, queryItems: [URLQueryItem] = []) async throws -> Model? {
        try await fetch(endpoint: endpoint, queryItems: queryItems).first
    }

    /// Performs the request and hands the raw payload over for decoding.
    private func fetchData<Result>(
        endpoint: APIEndpoint,
        queryItems: [URLQueryItem] = [],
        decode: (Data) throws -> Result
    ) async throws -> Result {
        let url = try makeURL(endpoint: endpoint, queryItems: queryItems)
        let data = try await fetchData(from: url)

        do {
            return try decode(data)
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkFailed(error)
        }
    }

    /// Performs the request, reporting every transport failure as `APIError.networkFailed`.
    private func fetchData(from url: URL) async throws -> Data {
        do {
            return try await networkClient.fetch(request: URLRequest(url: url))
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkFailed(error)
        }
    }

    /// Builds the request URL, appending the given query items to the endpoint's ones.
    private func makeURL(endpoint: APIEndpoint, queryItems: [URLQueryItem] = []) throws -> URL {
        guard let url = urlBuilder.build(endpoint: endpoint, queryItems: queryItems) else {
            throw APIError.invalidURL
        }

        return url
    }
}
