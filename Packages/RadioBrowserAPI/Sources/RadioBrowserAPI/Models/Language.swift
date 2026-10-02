import Foundation

/// Represents a language from the Radio-Browser API
public protocol Language {
    /// Name of the language
    var name: String { get }
    /// Number of stations broadcasting in this language
    var stationCount: Int { get }
}

/// Implementation of the Language protocol
internal struct LanguageObject: Codable, Language {
    public let name: String
    public let stationCount: Int
}
