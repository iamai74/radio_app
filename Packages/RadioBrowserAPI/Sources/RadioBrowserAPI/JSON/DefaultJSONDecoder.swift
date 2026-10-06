import Foundation

/// Decoder shared by every endpoint.
///
/// Models map their API counterparts explicitly (`stationuuid`, `iso_3166_1`,
/// `url_resolved`, ...), so JSON keys are consumed verbatim: a snake case conversion
/// strategy rewrites those keys and silently breaks the mapping.
///
/// The package owns the payload layout, so a caller supplied `JSONDecoder` is reconfigured
/// with the strategies below. Settings that say nothing about the layout —
/// `outputFormatting`, `userInfo` — are kept.
public final class DefaultJSONDecoder: JSONDecoderProtocol {
    private let decoder: JSONDecoder

    /// - Parameter decoder: The decoder to configure and use, defaults to a fresh one.
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            guard let date = RadioBrowserDate.date(from: value) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unsupported timestamp layout: '\(value)'"
                )
            }

            return date
        }
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}
