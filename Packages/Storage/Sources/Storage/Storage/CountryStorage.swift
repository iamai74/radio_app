import Foundation
import SwiftData
import Combine

@MainActor
final class CountryStorageImpl: BaseStorage<CountryEntityImpl, CountryFilter>, CountryStorage {
    var countriesPublisher: AnyPublisher<[any CountryEntity], Never> {
        publisher.map { $0 as [any CountryEntity] }.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, initial: [CountryEntityImpl] = []) {
        super.init(modelContext: modelContext, sortKeyPath: \.name, initial: initial)
    }

    func filteredPublisher(filter: CountryFilter) -> AnyPublisher<[any CountryEntity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] as [any CountryEntity] }
            .eraseToAnyPublisher()
    }

    override func applyFilter(_ filter: CountryFilter, to results: inout [CountryEntityImpl]) throws {
        if let name = filter.name, !name.isEmpty {
            results = results.filter { $0.name.localizedStandardContains(name) }
        }

        if let minCount = filter.minStationCount {
            results = results.filter { $0.stationCount >= minCount }
        }

        let sorted: [CountryEntityImpl]
        switch filter.orderBy {
        case .name:
            sorted = results.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .stationCount:
            sorted = results.sorted { $0.stationCount > $1.stationCount }
        }
        results = filter.reverse ? sorted.reversed() : sorted
    }
}
