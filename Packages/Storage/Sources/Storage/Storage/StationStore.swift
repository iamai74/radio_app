import Foundation
import SwiftData
import Combine

@MainActor
final class StationStore {
    private let storage: StationStorageImpl

    init(modelContext: ModelContext) {
        self.storage = StationStorageImpl(modelContext: modelContext)
    }

    func save(_ stations: [some StationEntity]) throws {
        let entities = stations.map { StationEntityImpl.from($0) }
        try storage.save(entities)
    }

    func publisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never> {
        storage.filteredPublisher(filter: filter)
    }

    func deleteAll() throws {
        try storage.deleteAll()
    }
}
