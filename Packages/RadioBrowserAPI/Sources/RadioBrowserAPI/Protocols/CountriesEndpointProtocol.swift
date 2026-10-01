import Foundation

public protocol CountriesEndpointProtocol: Sendable {
    func getCountries() async throws -> [Country]
    func getCountries(withFilter filter: String) async throws -> [Country]
}