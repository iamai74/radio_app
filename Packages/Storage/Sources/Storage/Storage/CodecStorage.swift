import Foundation
import SwiftData
import Combine

@MainActor
final class CodecStorageImpl: BaseStorage<CodecEntityImpl, CodecFilter>, CodecStorage {
    var codecsPublisher: AnyPublisher<[any CodecEntity], Never> {
        publisher.map { $0 as [any CodecEntity] }.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, initial: [CodecEntityImpl] = []) {
        super.init(modelContext: modelContext, sortKeyPath: \.name, initial: initial)
    }

    func filteredPublisher(filter: CodecFilter) -> AnyPublisher<[any CodecEntity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] as [any CodecEntity] }
            .eraseToAnyPublisher()
    }

    override func applyFilter(_ filter: CodecFilter, to results: inout [CodecEntityImpl]) throws {
        if let name = filter.name, !name.isEmpty {
            results = results.filter { $0.name.localizedStandardContains(name) }
        }

        if let minCount = filter.minStationCount {
            results = results.filter { $0.stationCount >= minCount }
        }

        let sorted: [CodecEntityImpl]
        switch filter.orderBy {
        case .name:
            sorted = results.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .stationCount:
            sorted = results.sorted { $0.stationCount > $1.stationCount }
        }
        results = filter.reverse ? sorted.reversed() : sorted
    }
}
