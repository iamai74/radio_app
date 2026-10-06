import Foundation
import SwiftData
import Combine

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

    func publisher(filter: StationFilter) -> AnyPublisher<[StationEntityImpl], Never> {
        storage.filteredPublisher(filter: filter)
    }

    func sequence(filter: StationFilter) -> StorageSequence<StationEntityImpl> {
        storage.filteredSequence(filter: filter)
    }

    func deleteAll() async throws {
        try await storage.deleteAll()
    }

    var failures: AnyPublisher<StorageError, Never> {
        storage.failureSubject.eraseToAnyPublisher()
    }
}
