import Foundation

/// A radio station as the storage layer sees it. Deliberately free of any
/// persistence detail so callers can hand their own model types to `DataStore`.
public protocol StationEntity: Sendable {
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

/// Non-Sendable base protocol for internal SwiftData models.
/// SwiftData @Model classes cannot be Sendable, so we separate the
/// persistence-facing protocol from the public Sendable protocol.
public protocol StationEntityBase {
    var id: String { get set }
    var name: String { get set }
    var url: String { get set }
    var homepage: String? { get set }
    var favicon: String? { get set }
    var tags: [String]? { get set }
    var country: String { get set }
    var state: String? { get set }
    var language: String? { get set }
    var votes: Int { get set }
    var codec: String? { get set }
    var bitrate: Int? { get set }
    var lastCheckOk: Bool { get set }
    var lastCheckTime: Date? { get set }
    var lastCheckTotal: Int { get set }
    var lastCheckFailures: Int { get set }
    var lastCheckDuration: Int { get set }
    var lastCheckError: String? { get set }
    var lastChangeTime: Date? { get set }
    var changeCounter: Int { get set }
    var creationTime: Date? { get set }
    var urlResolved: String? { get set }
}
