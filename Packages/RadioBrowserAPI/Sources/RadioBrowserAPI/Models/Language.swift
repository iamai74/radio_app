import Foundation

/// A protocol representing an language.
public protocol Language: Decodable, Sendable {
    /// The name of the codec.
    var name: String { get }

    /// The number of stations broadcasting in this language.
    var stationCount: Int { get }
}

/// An internal struct implementing the Language protocol with Codable conformance.
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
