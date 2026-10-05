import Foundation
import SwiftData
import Combine

@MainActor
final class FacetStore<Entity: PersistentModel & FacetEntity & StorageUpsertKey & Hashable> {
    private let storage: FacetStorageImpl<Entity>

    init(modelContext: ModelContext) {
        self.storage = FacetStorageImpl(modelContext: modelContext)
    }

    func save(_ entities: [Entity]) throws {
        try storage.save(entities)
    }

    func publisher(filter: FacetFilter) -> AnyPublisher<[Entity], Never> {
        storage.filteredPublisher(filter: filter)
    }

    func deleteAll() throws {
        try storage.deleteAll()
    }
}
