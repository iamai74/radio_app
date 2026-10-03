import Foundation

/// Performs the HTTP requests against the Radio Browser service.
///
/// The client owns the transport level contract: it attaches the user agent the service asks
/// for and translates every non successful response into an `APIError`, so the endpoints only
/// deal with decoding.
public final class DefaultNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let userAgent: String

    /// - Parameters:
    ///   - session: The session performing the requests.
    ///   - userAgent: The user agent header value, required by the service to accept requests.
    public init(session: URLSession = .shared, userAgent: String = "RadioApp/1.0") {
        self.session = session
        self.userAgent = userAgent
    }

    /// Performs the request and returns the payload.
    /// - Parameter request: The request to perform.
    /// - Returns: The response body.
    /// - Throws: `APIError.httpError` for any non 2xx status, `APIError.invalidResponse` when
    /// the response is not an HTTP response and `APIError.networkFailed` for transport errors.
    public func fetch(request: URLRequest) async throws -> Data {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
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
