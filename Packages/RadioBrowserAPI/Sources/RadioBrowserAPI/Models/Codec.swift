import Foundation

/// A protocol representing an audio codec.
///
/// Decoding deliberately stays off the read model: only ``CodecObject`` knows how to turn
/// the payload of the service into a codec, while consumers depend on the value
/// properties below.
public protocol Codec: StationCounted {}

/// The payload of the service, implementing ``Codec`` with a Codable conformance.
package struct CodecObject: Codable, Codec {
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
