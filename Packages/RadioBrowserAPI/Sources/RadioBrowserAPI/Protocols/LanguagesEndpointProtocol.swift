import Foundation

public protocol LanguagesEndpointProtocol: Sendable {
    func getLanguages() async throws -> [any Language]
    func getLanguages(withFilter filter: String) async throws -> [any Language]
}
