import Foundation

/// Every failure the Radio Browser client can report.
///
/// `isRetryable` tells whether another attempt — possibly against another mirror — can
/// succeed. It drives the failover performed by the endpoints and is the only thing a
/// caller needs to decide whether to surface an error to the user or to try again.
public enum APIError: Error, LocalizedError, Equatable {
    /// The request URL could not be built from the base URL and the endpoint path.
    case invalidURL
    /// The transport answered with something that is not an HTTP response.
    case invalidResponse
    /// The payload did not match the expected layout.
    case decodingFailed(Error)
    /// The request never reached the service.
    case networkFailed(Error)
    /// The failure belongs to none of the other categories.
    ///
    /// The safety net for custom ``JSONDecoderProtocol`` implementations: a decoder that
    /// throws something which is neither a `DecodingError` nor an `APIError` still reaches
    /// the caller as a typed failure instead of escaping the error contract.
    case undetermined(Error)
    /// The service answered with a non 2xx status code.
    case httpError(Int)

    /// The HTTP status code of an `httpError`, or `nil` for every other case.
    public var statusCode: Int? {
        guard case .httpError(let statusCode) = self else {
            return nil
        }

        return statusCode
    }

    /// Whether repeating the request can plausibly succeed.
    ///
    /// Cancellations are never retryable: retrying them would fight the surrounding task.
    public var isRetryable: Bool {
        switch self {
        case .invalidResponse:
            return true
        case .networkFailed(let error):
            if error is CancellationError {
                return false
            }
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return false
            }

            return true
        case .httpError(let statusCode):
            return statusCode == 408 || statusCode == 429 || (500...599).contains(statusCode)
        case .invalidURL, .decodingFailed, .undetermined:
            return false
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .undetermined(let error):
            return "Request failed: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP Error \(statusCode)"
        }
    }

    /// Underlying errors are compared by a stable identity — domain and code of the
    /// bridged `NSError` — instead of their description: `localizedDescription` varies
    /// with the system language, so comparing it would make equality locale dependent.
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL), (.invalidResponse, .invalidResponse):
            return true
        case (.httpError(let lhsCode), .httpError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)),
             (.networkFailed(let lhsError), .networkFailed(let rhsError)),
             (.undetermined(let lhsError), .undetermined(let rhsError)):
            return sameIdentity(lhsError, rhsError)
        default:
            return false
        }
    }

    /// Whether two errors are the same failure: equal `NSError` domain and code after
    /// bridging, which is stable across locales and process runs.
    private static func sameIdentity(_ lhs: Error, _ rhs: Error) -> Bool {
        let lhsError = lhs as NSError
        let rhsError = rhs as NSError

        return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
    }
}
