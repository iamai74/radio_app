import Foundation

public protocol TagsEndpointProtocol: Sendable {
    func getTags() async throws -> [Tag]
    func getTags(withFilter filter: String) async throws -> [Tag]
}
