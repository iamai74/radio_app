import Foundation

/// Represents a codec from the Radio-Browser API
public protocol Codec {
    /// Name of the codec
    var name: String { get }
    /// Number of stations using this codec
    var stationCount: Int { get }
}

/// Implementation of the Codec protocol
internal struct CodecObject: Codable, Codec {
    public let name: String
    public let stationCount: Int
    
    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}