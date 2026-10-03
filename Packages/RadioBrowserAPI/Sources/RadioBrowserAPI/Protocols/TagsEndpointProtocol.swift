import Foundation

public protocol TagsEndpointProtocol: Sendable {
    func getTags() async throws -> [any Tag]
    func getTags(withFilter filter: String) async throws -> [any Tag]
}
