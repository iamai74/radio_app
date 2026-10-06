import Foundation

/// A protocol representing a tag.
public protocol Tag: StationCounted {}

/// The payload of the service, implementing ``Tag`` with a Codable conformance.
package struct TagObject: Codable, Tag {
    public let name: String
    public let stationCount: Int

    package init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case stationCount = "stationcount"
    }
}
