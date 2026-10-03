import Foundation

/// A protocol representing a country.
public protocol Country: Decodable, Sendable {
    /// The full name of the country.
    var name: String { get }

    /// The ISO 3166-1 alpha-2 code for the country.
    var code: String { get }

    /// The number of stations in this country.
    var stationCount: Int { get }
}

/// An public struct implementing the Country protocol with Codable conformance.
public struct CountryObject: Codable, Country {
    public let name: String
    public let code: String
    public let stationCount: Int

    private enum CodingKeys: String, CodingKey {
        case name
        case code = "iso_3166_1"
        case stationCount = "stationcount"
    }
}
