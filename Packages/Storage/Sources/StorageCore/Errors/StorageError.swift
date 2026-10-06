import Foundation

/// Every failure the storage layer can surface.
///
/// Reads and writes report this instead of logging and continuing, so a caller
/// can tell "the fetch broke" apart from "the write failed". Read errors reach
/// consumers through `StorageFailures.failures` / `StorageSequence`, never by
/// being turned into an empty result.
///
/// `underlying` carries the original error for programmatic handling (e.g. a
/// unique-constraint violation on upsert); `details` is the display string.
/// `Equatable` compares case + `details` only — underlying errors never
/// participate, so message-driven equality cannot be broken by wrapping.
public enum StorageError: Error {
    case fetchFailed(details: String, underlying: (any Error)? = nil)
    case saveFailed(details: String, underlying: (any Error)? = nil)

    /// The display detail, without the underlying error.
    public var details: String {
        switch self {
        case let .fetchFailed(details, _), let .saveFailed(details, _):
            details
        }
    }
}

extension StorageError: Equatable {
    public static func == (lhs: StorageError, rhs: StorageError) -> Bool {
        switch (lhs, rhs) {
        case let (.fetchFailed(lhsDetails, _), .fetchFailed(rhsDetails, _)):
            lhsDetails == rhsDetails
        case let (.saveFailed(lhsDetails, _), .saveFailed(rhsDetails, _)):
            lhsDetails == rhsDetails
        default:
            false
        }
    }
}

extension StorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .fetchFailed(details, _):
            "Storage fetch failed: \(details)"
        case let .saveFailed(details, _):
            "Storage save failed: \(details)"
        }
    }
}
