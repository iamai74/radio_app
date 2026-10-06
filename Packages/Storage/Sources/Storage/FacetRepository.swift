import Foundation
import SwiftData
import Combine

/// Read/write access to one facet kind: DTO mapping plus the filtering
/// pipeline. All four facets (country, tag, language, codec) share this
/// implementation; only the model and DTO types differ.
@MainActor
final class FacetRepository<Impl, DTO>
where Impl: PersistentModel & FacetEntity & StorageModel & Hashable, Impl.DTO == DTO {
    private let storage: EntityStorage<Impl, FacetFilter>

    init(modelContext: ModelContext) {
        self.storage = EntityStorage(modelContext: modelContext, strategy: .facet)
    }

    func save(_ dtos: [DTO]) async throws {
        try await storage.save(dtos.map { Impl.persist($0) })
    }

    func publisher(filter: FacetFilter) -> AnyPublisher<[Impl], Never> {
        storage.filteredPublisher(filter: filter)
    }

    func sequence(filter: FacetFilter) -> StorageSequence<Impl> {
        storage.filteredSequence(filter: filter)
    }

    func deleteAll() async throws {
        try await storage.deleteAll()
    }

    var failures: AnyPublisher<StorageError, Never> {
        storage.failureSubject.eraseToAnyPublisher()
    }
}
