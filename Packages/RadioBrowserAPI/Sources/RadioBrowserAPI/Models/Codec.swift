import Foundation

/// A protocol representing an audio codec.
public protocol Codec: Decodable, Sendable {
    /// The name of the codec.
    var name: String { get }

    /// The number of stations using this codec.
    var stationCount: Int { get }
}

/// An internal struct implementing the Codec protocol with Codable conformance.
internal struct CodecObject: Codable, Codec {
    public let name: String
    public let stationCount: Int

    private enum CodingKeys: String, CodingKey {
        case name
        case stationCount = "stationcount"
    }
}
