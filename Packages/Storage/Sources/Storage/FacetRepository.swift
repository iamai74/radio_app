import Foundation
import SwiftData
import Combine
import StorageCore

/// Read/write access to one facet kind: DTO mapping plus the filtering
/// pipeline. All four facets (country, tag, language, codec) share this
/// implementation; only the model and DTO types differ.
///
/// Adding a fifth facet kind touches: a `*Entity` protocol in `StorageCore`,
/// a `*Record` default DTO, an `@Model` + `StorageModel` conformance in
/// `Models/`, one `FacetRepository` property + forwarding block in
/// `DataStore`, and two entries in `StorageContainer`'s schema.
@MainActor
final class FacetRepository<Impl, DTO>
where Impl: PersistentModel & FacetEntity & StorageModel & Hashable, Impl.DTO == DTO, DTO: Sendable {
    private let storage: EntityStorage<Impl, FacetFilter>

    init(modelContext: ModelContext) {
        self.storage = EntityStorage(modelContext: modelContext, strategy: .facet)
    }

    func save(_ dtos: [DTO]) async throws {
        try await storage.save(dtos.map { Impl.persist($0) })
    }

    func publisher(filter: FacetFilter) -> AnyPublisher<[DTO], Never> {
        storage.filteredPublisher(filter: filter)
            .map { $0.map { $0.toDTO() } }
            .eraseToAnyPublisher()
    }

    func sequence(filter: FacetFilter) -> StorageSequence<DTO> {
        let publisher = storage.filteredPublisher(filter: filter)
            .map { $0.map { $0.toDTO() } }
            .eraseToAnyPublisher()
        return StorageSequence(values: publisher, failures: storage.failureSubject.eraseToAnyPublisher())
    }

    func deleteAll() async throws {
        try await storage.deleteAll()
    }

    var failures: AnyPublisher<StorageError, Never> {
        storage.failureSubject.eraseToAnyPublisher()
    }

    var cachedFilterCount: Int {
        storage.cachedFilterCount
    }
}
