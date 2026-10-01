import Foundation
import SwiftData
import Combine

@MainActor
final class TagStorageImpl: BaseStorage<TagEntityImpl, TagFilter>, TagStorage {
    var tagsPublisher: AnyPublisher<[any TagEntity], Never> {
        publisher.map { $0 as [any TagEntity] }.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, initial: [TagEntityImpl] = []) {
        super.init(modelContext: modelContext, sortKeyPath: \.name, initial: initial)
    }

    func filteredPublisher(filter: TagFilter) -> AnyPublisher<[any TagEntity], Never> {
        filteredSubjects
            .map { $0[filter] ?? [] as [any TagEntity] }
            .eraseToAnyPublisher()
    }

    override func applyFilter(_ filter: TagFilter, to results: inout [TagEntityImpl]) throws {
        if let name = filter.name, !name.isEmpty {
            results = results.filter { $0.name.localizedStandardContains(name) }
        }

        if let minCount = filter.minStationCount {
            results = results.filter { $0.stationCount >= minCount }
        }

        let sorted: [TagEntityImpl]
        switch filter.orderBy {
        case .name:
            sorted = results.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .stationCount:
            sorted = results.sorted { $0.stationCount > $1.stationCount }
        }
        results = filter.reverse ? sorted.reversed() : sorted
    }
}
