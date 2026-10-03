import Foundation

/// Base class for endpoint implementations that handles common API communication logic.
///
/// The class is generic over the concrete `Model` used for decoding, which keeps the
/// decoding implementation details (e.g. `StationObject`) inside the package while
/// subclasses may still expose either of the two flavours to their callers:
/// - concrete structs via `fetch(endpoint:queryItems:)` / `fetchObject(_:endpoint:)`;
/// - model protocols via `fetch(endpoint:queryItems:exposing:)`, which erases the
///   decoded structs into the protocol abstraction the client consumes.
open class BaseEndpoint<Model: Decodable> {
    let networkClient: NetworkClientProtocol
    let urlBuilder: URLBuilder
    let jsonDecoder: JSONDecoderProtocol

    /// Initializes the endpoint with its collaborators.
    /// - Parameters:
    ///   - networkClient: The client performing the HTTP requests.
    ///   - urlBuilder: The builder turning an endpoint into a `URL`.
    ///   - jsonDecoder: The decoder turning the response into models.
    public init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder = URLBuilder(), jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()) {
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

    /// Fetches a single object of the given decodable type from the given endpoint.
    /// - Parameters:
    ///   - objectType: The concrete type to decode the response into.
    ///   - endpoint: The API endpoint to fetch the object from.
    /// - Returns: The decoded object.
    /// - Throws: `APIError` for invalid URL, decoding failures and network failures.
    func fetchObject<Object: Decodable>(_ objectType: Object.Type, endpoint: APIEndpoint) async throws -> Object {
        try await fetchData(endpoint: endpoint, decode: { try self.jsonDecoder.decode(objectType, from: $0) })
    }

    /// Performs the request and hands the raw payload over for decoding.
    private func fetchData<Result>(
        endpoint: APIEndpoint,
        queryItems: [URLQueryItem] = [],
        decode: (Data) throws -> Result
    ) async throws -> Result {
        let url = try makeURL(endpoint: endpoint, queryItems: queryItems)
        let data = try await networkClient.fetch(request: URLRequest(url: url))

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

    /// Builds the request URL, appending the given query items to the endpoint's ones.
    private func makeURL(endpoint: APIEndpoint, queryItems: [URLQueryItem] = []) throws -> URL {
        var mergedQueryItems = endpoint.queryItems
        mergedQueryItems.append(contentsOf: queryItems)

        guard let url = urlBuilder.build(endpoint: endpoint, queryItems: mergedQueryItems) else {
            throw APIError.invalidURL
        }

        return url
    }
}
