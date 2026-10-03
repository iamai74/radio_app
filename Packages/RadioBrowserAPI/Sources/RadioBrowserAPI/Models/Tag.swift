import Foundation

/// A protocol representing a tag.
public protocol Tag: Decodable, Sendable {
    /// The name of the tag.
    var name: String { get }

    /// The number of stations with this tag.
    var stationCount: Int { get }
}

/// An internal struct implementing the Tag protocol with Codable conformance.
internal struct TagObject: Codable, Tag {
    public let name: String
    public let stationCount: Int

    private enum CodingKeys: String, CodingKey {
        case name
        case stationCount = "stationcount"
    }
}
