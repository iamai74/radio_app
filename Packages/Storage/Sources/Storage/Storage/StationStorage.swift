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

    // MARK: - SQLite Predicate Hooks

    override func predicate(for filter: StationFilter) -> Predicate<StationEntityImpl>? {
        if let name = filter.name, !name.isEmpty, let country = filter.country, let language = filter.language {
            return #Predicate<StationEntityImpl> {
                $0.name.localizedStandardContains(name) && $0.country == country && $0.language == language
            }
        } else if let name = filter.name, !name.isEmpty, let country = filter.country {
            return #Predicate<StationEntityImpl> {
                $0.name.localizedStandardContains(name) && $0.country == country
            }
        } else if let name = filter.name, !name.isEmpty, let language = filter.language {
            return #Predicate<StationEntityImpl> {
                $0.name.localizedStandardContains(name) && $0.language == language
            }
        } else if let name = filter.name, !name.isEmpty {
            return #Predicate<StationEntityImpl> {
                $0.name.localizedStandardContains(name)
            }
        } else if let country = filter.country, let language = filter.language {
            return #Predicate<StationEntityImpl> {
                $0.country == country && $0.language == language
            }
        } else if let country = filter.country {
            return #Predicate<StationEntityImpl> {
                $0.country == country
            }
        } else if let language = filter.language {
            return #Predicate<StationEntityImpl> {
                $0.language == language
            }
        }
        return nil
    }

    override func sortDescriptors(from filter: StationFilter) -> [SortDescriptor<StationEntityImpl>]? {
        let direction: SortOrder = filter.reverse ? .reverse : .forward

        switch filter.orderBy {
        case .name:
            return [SortDescriptor(\StationEntityImpl.name, order: direction)]
        case .votes:
            return [SortDescriptor(\StationEntityImpl.votes, order: direction)]
        case .bitrate:
            return [SortDescriptor(\StationEntityImpl.bitrate, order: direction)]
        case .changeCounter:
            return [SortDescriptor(\StationEntityImpl.changeCounter, order: direction)]
        case .lastCheckOk:
            return nil
        }
    }

    override func fetchOffset(from filter: StationFilter) -> Int? {
        filter.offset
    }

    override func fetchLimit(from filter: StationFilter) -> Int? {
        filter.limit
    }

    /// Post-process results from predicate fetch for filters/sorts not expressible in SQLite.
    override func applyPostFilter(_ filter: StationFilter, to results: inout [StationEntityImpl]) {
        guard filter.hasPostProcessing else { return }

        if let tag = filter.tag, !tag.isEmpty {
            results = results.filter { station in
                station.tags?.contains(where: { $0.localizedStandardContains(tag) }) ?? false
            }
        }

        if filter.orderBy == .lastCheckOk {
            let sorted = results.sorted { $0.lastCheckOk && !$1.lastCheckOk }
            results = filter.reverse ? sorted.reversed() : sorted
        }
    }

    // MARK: - In-Memory Fallback

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
                station.tags?.contains(where: { $0.localizedStandardContains(tag) }) ?? false
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
