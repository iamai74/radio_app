import Foundation
import SwiftData
import Combine
import StorageCore

/// Read/write access to stations: DTO mapping plus the filtering pipeline.
///
/// One layer instead of the previous `StationStore` → `StationStorageImpl`
/// pair — the second layer only ever forwarded calls.
@MainActor
final class StationRepository {
    private let storage: EntityStorage<StationEntityImpl, StationFilter>

    init(modelContext: ModelContext) {
        self.storage = EntityStorage(modelContext: modelContext, strategy: .station)
    }

    func save(_ stations: [some StationEntity]) async throws {
        try await storage.save(stations.map { StationEntityImpl.persist($0) })
    }

    func publisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never> {
        storage.filteredPublisher(filter: filter)
            .map { $0.map { $0.toDTO() } }
            .eraseToAnyPublisher()
    }

    func sequence(filter: StationFilter) -> StorageSequence<any StationEntity> {
        let base = StorageSequence(
            values: storage.filteredPublisher(filter: filter)
                .map { $0.map { $0.toDTO() } }
                .eraseToAnyPublisher(),
            failures: storage.failureSubject.eraseToAnyPublisher()
        )
        return base.map { $0 as [any StationEntity] }
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
