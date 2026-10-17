import Foundation

public enum ImageStorageError: Error, Sendable {
    case storageDirectoryUnavailable
    case fileNotFound(String)
    case writeFailed(String)
    case readFailed(String)
    case deleteFailed(String)
    case invalidKey
}

extension ImageStorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .storageDirectoryUnavailable:
            "Could not access the storage directory."
        case .fileNotFound(let key):
            "Image not found for key: \(key)."
        case .writeFailed(let key):
            "Failed to write image for key: \(key)."
        case .readFailed(let key):
            "Failed to read image for key: \(key)."
        case .deleteFailed(let key):
            "Failed to delete image for key: \(key)."
        case .invalidKey:
            "Invalid image storage key."
        }
    }
}
