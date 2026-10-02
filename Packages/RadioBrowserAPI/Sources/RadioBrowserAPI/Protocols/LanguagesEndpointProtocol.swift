import Foundation

public protocol LanguagesEndpointProtocol: Sendable {
    func getLanguages() async throws -> [Language]
    func getLanguages(withFilter filter: String) async throws -> [Language]
}
