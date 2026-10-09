import Foundation
import SwiftData
import Combine
import Storage

@MainActor
final class FacetRepository<Impl: PersistentModel & FacetEntity & StorageModel & Hashable, DTO: Sendable>
where Impl.DTO == DTO {
    private let storage: EntityStorage<Impl, FacetFilter>

    init(modelContext: ModelContext) {
        self.storage = EntityStorage(modelContext: modelContext, strategy: .facet)
    }

    func save(_ dtos: [DTO]) async throws {
        try await storage.save(dtos.map { Impl.persist($0) })
    }

    func publisher(filter: FacetFilter) -> AnyPublisher<[DTO], Never> {
        storage.publisher(filter: filter)
            .map { $0.map { $0.toDTO() } }
            .eraseToAnyPublisher()
    }

    func sequence(filter: FacetFilter) -> StorageSequence<DTO> {
        let values = storage.publisher(filter: filter)
            .map { $0.map { $0.toDTO() } }
            .eraseToAnyPublisher()
        return StorageSequence(values: values, failures: storage.failureSubject.eraseToAnyPublisher())
    }

    func deleteAll() async throws {
        try await storage.deleteAll()
    }

    func reload() {
        storage.reload()
    }

    var failures: AnyPublisher<StorageError, Never> {
        storage.failureSubject.eraseToAnyPublisher()
    }

    var cachedFilterCount: Int {
        storage.cachedFilterCount
    }
}
