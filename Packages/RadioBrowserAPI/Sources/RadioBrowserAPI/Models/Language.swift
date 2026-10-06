import Foundation

/// A protocol representing a language.
public protocol Language: StationCounted {}

/// The payload of the service, implementing ``Language`` with a Codable conformance.
package struct LanguageObject: Codable, Language {
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
