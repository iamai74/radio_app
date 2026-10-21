import Foundation
import Combine
import RadioBrowserAPI
import Storage
import UILibrary

@MainActor
final class StationsService {
    private let api: RadioBrowserAPI
    private let dataStore: any StationWriting
    private let reader: any StationReading

    init(api: RadioBrowserAPI, dataStore: any StationWriting, reader: any StationReading) {
        self.api = api
        self.dataStore = dataStore
        self.reader = reader
    }

    func stationsPublisher(filter: StationFilter = .empty) -> AnyPublisher<[any UILibrary.Station], Never> {
        reader.stationsPublisher(filter: filter)
            .map { (entities: [any StationEntity]) -> [any UILibrary.Station] in
                entities.map { entity in
                    StorageStation(from: entity)
                }
            }
            .eraseToAnyPublisher()
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

    private static func adapt(_ stations: [any ApiStation]) async -> [StationRecord] {
        await Task.detached(priority: .utility) {
            stations.map { StationRecord(from: $0) }
        }.value
    }
}
