import Foundation

/// Every failure the storage layer can surface.
///
/// Reads and writes report this instead of logging and continuing, so a caller
/// can tell "the fetch broke" apart from "the write failed". Read errors reach
/// consumers through `StorageFailures.failures` / `StorageSequence`, never by
/// being turned into an empty result.
public enum StorageError: Error, Equatable {
    case fetchFailed(String)
    case saveFailed(String)
}

extension StorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .fetchFailed(details):
            "Storage fetch failed: \(details)"
        case let .saveFailed(details):
            "Storage save failed: \(details)"
        }
    }
}
