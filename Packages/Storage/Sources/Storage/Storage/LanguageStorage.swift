import Foundation
import SwiftData
import Combine

@MainActor
final class LanguageStorageImpl: BaseStorage<LanguageEntityImpl, LanguageFilter>, LanguageStorage {
    var languagesPublisher: AnyPublisher<[any LanguageEntity], Never> {
        publisher.map { $0 as [any LanguageEntity] }.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, initial: [LanguageEntityImpl] = []) {
        super.init(modelContext: modelContext, sortKeyPath: \.name, initial: initial)
    }

    func filteredPublisher(filter: LanguageFilter) -> AnyPublisher<[any LanguageEntity], Never> {
        filteredSubjects
            .map { $0[filter] ?? [] as [any LanguageEntity] }
            .eraseToAnyPublisher()
    }

    override func applyFilter(_ filter: LanguageFilter, to results: inout [LanguageEntityImpl]) throws {
        if let name = filter.name, !name.isEmpty {
            results = results.filter { $0.name.localizedStandardContains(name) }
        }

        if let minCount = filter.minStationCount {
            results = results.filter { $0.stationCount >= minCount }
        }

        let sorted: [LanguageEntityImpl]
        switch filter.orderBy {
        case .name:
            sorted = results.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .stationCount:
            sorted = results.sorted { $0.stationCount > $1.stationCount }
        }
        results = filter.reverse ? sorted.reversed() : sorted
    }
}
