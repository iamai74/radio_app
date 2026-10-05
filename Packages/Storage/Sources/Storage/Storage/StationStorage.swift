import Foundation
import SwiftData
import Combine

@MainActor
final class StationStorageImpl: BaseStorage<StationEntityImpl, StationFilter>, StationStorage {
    var stationsPublisher: AnyPublisher<[any StationEntity], Never> {
        publisher.map { $0 as [any StationEntity] }.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext, initial: [StationEntityImpl] = []) {
        super.init(modelContext: modelContext, sortKeyPath: \.name, initial: initial)
    }

    func filteredPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never> {
        registerFilter(filter)
        return filteredSubjects
            .map { $0[filter] ?? [] as [any StationEntity] }
            .eraseToAnyPublisher()
    }

    // swiftlint:disable:next cyclomatic_complexity
    override func applyFilter(_ filter: StationFilter, to results: inout [StationEntityImpl]) throws {
        if let name = filter.name, !name.isEmpty {
            results = results.filter { $0.name.localizedStandardContains(name) }
        }

        if let country = filter.country {
            results = results.filter { $0.country == country }
        }

        if let language = filter.language {
            results = results.filter { $0.language == language }
        }

        if let tag = filter.tag, !tag.isEmpty {
            results = results.filter { station in
                station.tags?.contains(where: { $0.localizedCaseInsensitiveContains(tag) }) ?? false
            }
        }

        let sorted: [StationEntityImpl]
        switch filter.orderBy {
        case .name:
            sorted = results.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .votes:
            sorted = results.sorted { $0.votes > $1.votes }
        case .bitrate:
            sorted = results.sorted { ($0.bitrate ?? 0) > ($1.bitrate ?? 0) }
        case .lastCheckOk:
            sorted = results.sorted { $0.lastCheckOk && !$1.lastCheckOk }
        case .changeCounter:
            sorted = results.sorted { $0.changeCounter > $1.changeCounter }
        }
        results = filter.reverse ? sorted.reversed() : sorted

        if let offset = filter.offset, offset > 0 {
            results = Array(results.dropFirst(offset))
        }

        if let limit = filter.limit, limit > 0 {
            results = Array(results.prefix(limit))
        }
    }
}
