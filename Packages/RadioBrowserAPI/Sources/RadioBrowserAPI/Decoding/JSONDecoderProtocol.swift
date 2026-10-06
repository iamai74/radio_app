import Foundation

public protocol JSONDecoderProtocol: Sendable {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
