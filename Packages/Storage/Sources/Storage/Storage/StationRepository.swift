import Foundation
import SwiftData
import Combine
import Storage

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
        storage.publisher(filter: filter)
            .map { $0.map { $0.toDTO() } }
            .eraseToAnyPublisher()
    }

    func sequence(filter: StationFilter) -> StorageSequence<any StationEntity> {
        let values = storage.publisher(filter: filter)
            .map { $0.map { $0.toDTO() as any StationEntity } }
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
