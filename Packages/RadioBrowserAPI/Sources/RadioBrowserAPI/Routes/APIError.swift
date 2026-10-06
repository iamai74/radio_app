import Foundation

/// Every failure the Radio Browser client can report.
///
/// `isRetryable` tells whether another attempt — possibly against another mirror — can
/// succeed. It drives the failover performed by ``FailoverTransport`` and is the only thing
/// a caller needs to decide whether to surface an error to the user or to try again.
///
/// Every failure the package throws is an `APIError`, cancellations included
/// (``cancelled``): a cancelled task never escapes as a bare `CancellationError`.
public enum APIError: Error, LocalizedError, Equatable, @unchecked Sendable {
    /// The request URL could not be built from the base URL and the endpoint path.
    case invalidURL
    /// The transport answered with something that is not an HTTP response.
    case invalidResponse
    /// The payload did not match the expected layout.
    ///
    /// `@unchecked Sendable` of this type exists for this case: `DecodingError` carries an
    /// `any Error` of its own and is not `Sendable`, while it is only ever moved across
    /// suspension points by `throws` — never shared concurrently.
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
    /// The request was cancelled before it completed — a cancelled `Task`, or a transport
    /// that reports `URLError.cancelled`.
    ///
    /// Cancellation is never retryable: retrying it would fight the surrounding task.
    case cancelled

    /// The HTTP status code of an `httpError`, or `nil` for every other case.
    public var statusCode: Int? {
        guard case .httpError(let statusCode) = self else {
            return nil
        }

        return statusCode
    }

    /// Whether repeating the request can plausibly succeed.
    public var isRetryable: Bool {
        switch self {
        case .invalidResponse:
            return true
        case .cancelled:
            return false
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
        case .cancelled:
            return "Request cancelled"
        }
    }

    /// Maps a failure raised by the transport layer into the package's error contract.
    ///
    /// An `APIError` passes through untouched, both spellings of a cancellation —
    /// `CancellationError` and `URLError(.cancelled)` — become ``cancelled``, and anything
    /// else becomes ``networkFailed(_:)``.
    static func fromTransport(_ error: Error) -> APIError {
        switch error {
        case let apiError as APIError:
            return apiError
        case is CancellationError:
            return .cancelled
        case let urlError as URLError where urlError.code == .cancelled:
            return .cancelled
        default:
            return .networkFailed(error)
        }
    }

    /// Maps a failure raised while turning a payload into models into the package's error
    /// contract: a `DecodingError` becomes ``decodingFailed(_:)``, an `APIError` passes
    /// through, and everything else becomes ``undetermined(_:)``.
    static func fromPayload(_ error: Error) -> APIError {
        switch error {
        case let apiError as APIError:
            return apiError
        case let decodingError as DecodingError:
            return .decodingFailed(decodingError)
        case is CancellationError:
            return .cancelled
        default:
            return .undetermined(error)
        }
    }

    /// Underlying errors are compared by a stable identity instead of their description:
    /// `localizedDescription` varies with the system language, so comparing it would make
    /// equality locale dependent.
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.cancelled, .cancelled):
            return true
        case (.httpError(let lhsCode), .httpError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return sameDecodingFailure(lhsError, rhsError)
        case (.networkFailed(let lhsError), .networkFailed(let rhsError)),
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

    /// Whether two decoding failures describe the same malformed payload.
    ///
    /// Bridging a `DecodingError` to `NSError` keeps only its case index, so two failures
    /// about *different* keys would compare equal through ``sameIdentity(_:_:)`` — the
    /// fingerprint below carries the coding path and the message instead.
    private static func sameDecodingFailure(_ lhs: Error, _ rhs: Error) -> Bool {
        guard let lhsDecoding = lhs as? DecodingError, let rhsDecoding = rhs as? DecodingError else {
            return sameIdentity(lhs, rhs)
        }

        return fingerprint(lhsDecoding) == fingerprint(rhsDecoding)
    }

    /// A locale independent description of a decoding failure: case, type, coding path and
    /// debug message.
    private static func fingerprint(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "typeMismatch(\(type)): \(fingerprint(context))"
        case .valueNotFound(let type, let context):
            return "valueNotFound(\(type)): \(fingerprint(context))"
        case .keyNotFound(let key, let context):
            return "keyNotFound(\(key.stringValue)): \(fingerprint(context))"
        case .dataCorrupted(let context):
            return "dataCorrupted: \(fingerprint(context))"
        @unknown default:
            return String(describing: error)
        }
    }

    private static func fingerprint(_ context: DecodingError.Context) -> String {
        "\(path(of: context.codingPath)) — \(context.debugDescription)"
    }

    private static func path(of codingPath: [CodingKey]) -> String {
        codingPath
            .map { key in
                key.intValue.map { "\(key.stringValue)[\($0)]" } ?? key.stringValue
            }
            .joined(separator: ".")
    }
}
