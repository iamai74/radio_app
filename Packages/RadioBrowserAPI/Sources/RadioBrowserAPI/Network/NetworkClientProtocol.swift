import Foundation

public protocol NetworkClientProtocol: Sendable {
    func fetch(url: URL) async throws -> Data
}