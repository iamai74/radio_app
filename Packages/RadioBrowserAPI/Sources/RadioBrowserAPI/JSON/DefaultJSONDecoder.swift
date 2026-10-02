import Foundation

public final class DefaultJSONDecoder: JSONDecoderProtocol {
    public init() {}

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
}
