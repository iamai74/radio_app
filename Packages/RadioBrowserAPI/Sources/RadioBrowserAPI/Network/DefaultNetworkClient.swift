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
    /// the response is not an HTTP response and `APIError.networkFailed` for transport errors.
    /// A cancellation is rethrown as is, so a cancelled task stays cancelled instead of being
    /// reported as a transport failure.
    public func fetch(request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as CancellationError {
            throw error
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkFailed(error)
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
