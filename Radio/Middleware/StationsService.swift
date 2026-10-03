import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class StationsService {
    private let api: RadioBrowserAPI
    private let dataStore: DataStore

    init(api: RadioBrowserAPI, dataStore: DataStore) {
        self.api = api
        self.dataStore = dataStore
    }

    func fetchAndSaveStations(
        country: String? = nil,
        language: String? = nil,
        tag: String? = nil,
        name: String? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws {
        let stations = try await api.stations.getStations(
            country: country,
            language: language,
            tag: tag,
            name: name,
            limit: limit,
            offset: offset,
            hideBreaks: true,
            order: "votes",
            reverse: true
        )

        let entities = stations.map { StationAdapter(from: $0) }
        try dataStore.saveStations(entities)
    }

    func fetchAndSaveAllStations() async throws {
        let stations = try await api.stations.getAllStations()
        let entities = stations.map { StationAdapter(from: $0) }
        try dataStore.saveStations(entities)
    }

    func searchAndSaveStations(query: String, limit: Int = 100) async throws {
        let stations = try await api.stations.searchStations(query: query, limit: limit)
        let entities = stations.map { StationAdapter(from: $0) }
        try dataStore.saveStations(entities)
    }
}
