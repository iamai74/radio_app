import Foundation

/// A radio station as the storage layer sees it. Deliberately free of any
/// persistence detail so callers can hand their own model types to `DataStore`.
public protocol StationEntity {
    var id: String { get }
    var name: String { get }
    var url: String { get }
    var homepage: String? { get }
    var favicon: String? { get }
    var tags: [String]? { get }
    var country: String { get }
    var state: String? { get }
    var language: String? { get }
    var votes: Int { get }
    var codec: String? { get }
    var bitrate: Int? { get }
    var lastCheckOk: Bool { get }
    var lastCheckTime: Date? { get }
    var lastCheckTotal: Int { get }
    var lastCheckFailures: Int { get }
    var lastCheckDuration: Int { get }
    var lastCheckError: String? { get }
    var lastChangeTime: Date? { get }
    var changeCounter: Int { get }
    var creationTime: Date? { get }
    var urlResolved: String? { get }
}
