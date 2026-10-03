import Foundation

public protocol CodecsEndpointProtocol: Sendable {
    func getAudioCodecs() async throws -> [any Codec]
}
