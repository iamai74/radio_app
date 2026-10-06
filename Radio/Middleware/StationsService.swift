import Foundation
import RadioBrowserAPI
import Storage

@MainActor
final class StationsService {
    private let api: RadioBrowserAPI
    private let dataStore: any StationWriting

    init(api: RadioBrowserAPI, dataStore: any StationWriting) {
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
            matching: StationQuery(
                country: country,
                language: language,
                tag: tag,
                name: name,
                limit: limit,
                offset: offset,
                hideBreaks: true,
                order: .votes,
                reverse: true
            )
        )

        let entities = stations.map { StationRecord(from: $0) }
        try await dataStore.saveStations(entities)
    }

    func fetchAndSaveAllStations() async throws {
        let stations = try await api.stations.getAllStations()
        // A full import maps tens of thousands of models, so the mapping runs off
        // the main actor as well; `DataStore.saveStations` writes on a background
        // context and only publication hops back.
        let entities = await Self.adapt(stations)
        try await dataStore.saveStations(entities)
    }

    func searchAndSaveStations(query: String, limit: Int = 100) async throws {
        let stations = try await api.stations.searchStations(query: query, limit: limit)
        let entities = stations.map { StationRecord(from: $0) }
        try await dataStore.saveStations(entities)
    }

    private static func adapt(_ stations: [any Station]) async -> [StationRecord] {
        await Task.detached(priority: .utility) {
            stations.map { StationRecord(from: $0) }
        }.value
    }
}
