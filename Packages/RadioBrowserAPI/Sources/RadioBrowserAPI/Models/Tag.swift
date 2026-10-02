import Foundation

/// Represents a tag from the Radio-Browser API
public protocol Tag {
    /// Name of the tag
    var name: String { get }
    /// Number of stations with this tag
    var stationCount: Int { get }
}

/// Implementation of the Tag protocol
internal struct TagObject: Codable, Tag {
    public let name: String
    public let stationCount: Int
}
