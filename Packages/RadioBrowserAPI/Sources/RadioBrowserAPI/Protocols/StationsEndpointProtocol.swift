import Foundation

public protocol StationsEndpointProtocol: Sendable {
    func getStations(
        country: String?,
        language: String?,
        tag: String?,
        name: String?,
        limit: Int,
        offset: Int,
        hideBroken: Bool,
        order: String,
        reverse: Bool
    ) async throws -> [Station]
    
    func getStation(byID id: String) async throws -> Station
    func searchStations(query: String, limit: Int) async throws -> [Station]
    func getStationsByCountry(_ country: String, limit: Int) async throws -> [Station]
    func getStationsByLanguage(_ language: String, limit: Int) async throws -> [Station]
    func getStationsByTag(_ tag: String, limit: Int) async throws -> [Station]
    func getAllStations() async throws -> [Station]
}