import Foundation

public protocol CountriesEndpointProtocol: Sendable {
    func getCountries() async throws -> [any Country]
    func getCountries(withFilter filter: String) async throws -> [any Country]
}
