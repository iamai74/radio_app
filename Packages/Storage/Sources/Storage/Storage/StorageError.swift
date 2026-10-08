import Foundation

public enum StorageError: Error, Equatable, Sendable {
    case saveFailed(details: String, underlying: (any Error)? = nil)
    case fetchFailed(details: String, underlying: (any Error)? = nil)
    case deleteFailed(details: String, underlying: (any Error)? = nil)

    public static func == (lhs: StorageError, rhs: StorageError) -> Bool {
        switch (lhs, rhs) {
        case (.saveFailed(let lDetails, _), .saveFailed(let rDetails, _)):
            return lDetails == rDetails
        case (.fetchFailed(let lDetails, _), .fetchFailed(let rDetails, _)):
            return lDetails == rDetails
        case (.deleteFailed(let lDetails, _), .deleteFailed(let rDetails, _)):
            return lDetails == rDetails
        default:
            return false
        }
    }
}
