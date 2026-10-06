import Foundation

/// Performs the HTTP requests against the Radio Browser service.
///
/// The client owns only the transport level contract: it sends the request it is given and
/// translates every non successful response into an `APIError`, so the endpoints only deal
/// with decoding. Everything a request carries — URL, query, timeout, cache policy and the
/// `User-Agent` the service asks for — is applied by ``RequestBuilder`` before the client
/// ever sees it.
public final class DefaultNetworkClient: NetworkClientProtocol {
    private let session: URLSession

    /// - Parameter session: The session performing the requests.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Performs the request and returns the payload.
    /// - Parameter request: The request to perform.
    /// - Returns: The response body.
    /// - Throws: `APIError.httpError` for any non 2xx status, `APIError.invalidResponse` when
    /// the response is not an HTTP response, `APIError.networkFailed` for transport errors
    /// and `APIError.cancelled` for a cancelled task — a cancellation stays a typed
    /// `APIError` instead of escaping as a bare `CancellationError`.
    public func fetch(request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.fromTransport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return data
    }
}
