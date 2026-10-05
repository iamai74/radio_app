import Foundation
import SwiftData
import Combine

@MainActor
final class FacetStore<Entity: PersistentModel & FacetEntity & StorageUpsertKey & Hashable> {
    private let storage: FacetStorageImpl<Entity>

    init(modelContext: ModelContext) {
        self.storage = FacetStorageImpl(modelContext: modelContext)
    }

    func save(_ entities: [Entity]) async throws {
        try await storage.save(entities)
    }

    func publisher(filter: FacetFilter) -> AnyPublisher<[Entity], Never> {
        storage.filteredPublisher(filter: filter)
    }

    func sequence(filter: FacetFilter) -> StorageSequence<Entity> {
        storage.filteredSequence(filter: filter)
    }

    func deleteAll() async throws {
        try await storage.deleteAll()
    }
}
