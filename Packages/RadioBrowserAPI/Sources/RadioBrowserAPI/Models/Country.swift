import Foundation

/// Represents a country from the Radio-Browser API
public protocol Country {
    /// Name of the country
    var name: String { get }
    /// ISO 3166-1 alpha-2 code for the country
    var iso31661: String { get }
    /// Number of stations in this country
    var stationCount: Int { get }
}

/// Implementation of the Country protocol
internal struct CountryObject: Codable, Country {
    public let name: String
    public let iso31661: String
    public let stationCount: Int
    
    init(name: String, iso31661: String, stationCount: Int) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }
}
