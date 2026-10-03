import Foundation

public final class DefaultJSONDecoder: JSONDecoderProtocol {
    private let decoder: JSONDecoder

    public init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        // Keep caller-provided strategies if explicitly set; otherwise apply sensible defaults.
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}
