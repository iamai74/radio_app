import Foundation
import SwiftData
import Combine

@MainActor
final class StationStore {
    private let storage: StationStorageImpl

    init(modelContext: ModelContext) {
        self.storage = StationStorageImpl(modelContext: modelContext)
    }

    func save(_ stations: [some StationEntity]) async throws {
        let entities = stations.map { StationEntityImpl.from($0) }
        try await storage.save(entities)
    }

    func publisher(filter: StationFilter) -> AnyPublisher<[StationEntityImpl], Never> {
        storage.filteredPublisher(filter: filter)
    }

    func sequence(filter: StationFilter) -> StorageSequence<StationEntityImpl> {
        storage.filteredSequence(filter: filter)
    }

    func deleteAll() async throws {
        try await storage.deleteAll()
    }
}
