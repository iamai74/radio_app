import Foundation

/// A protocol representing a country.
public protocol Country: Decodable, Sendable {
    /// The full name of the country, as reported by the API.
    var name: String { get }

    /// The ISO 3166-1 alpha-2 code of the country, mirroring the `iso_3166_1` API field.
    var iso31661: String { get }

    /// The number of stations in this country.
    var stationCount: Int { get }
}

/// An internal struct implementing the Country protocol with Codable conformance.
package struct CountryObject: Codable, Country {
    public let name: String
    public let iso31661: String
    public let stationCount: Int

    package init(name: String, iso31661: String, stationCount: Int) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case iso31661 = "iso_3166_1"
        case stationCount = "stationcount"
    }
}
