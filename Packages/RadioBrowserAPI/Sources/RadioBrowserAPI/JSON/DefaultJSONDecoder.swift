import Foundation

/// Decoder shared by every endpoint.
///
/// Models map their API counterparts explicitly (`stationuuid`, `iso_3166_1`,
/// `url_resolved`, ...), so JSON keys are consumed verbatim: a snake case conversion
/// strategy rewrites those keys and silently breaks the mapping.
public final class DefaultJSONDecoder: JSONDecoderProtocol {
    private let decoder: JSONDecoder

    public init() {
        decoder = JSONDecoder()
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

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        // Keep caller-provided strategies if explicitly set; otherwise apply sensible defaults.
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}
