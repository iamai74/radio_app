import Foundation
import SwiftData
import Combine

@MainActor
class FacetStorageImpl<Entity: PersistentModel & FacetEntity & StorageUpsertKey & Hashable>: BaseStorage<Entity, FacetFilter> {
    init(modelContext: ModelContext) {
        super.init(modelContext: modelContext, sortKeyPath: \.name)
    }

    override func predicate(for filter: FacetFilter) -> Predicate<Entity>? {
        if let name = filter.name, !name.isEmpty, let minCount = filter.minStationCount {
            return #Predicate<Entity> {
                $0.name.localizedStandardContains(name) && $0.stationCount >= minCount
            }
        } else if let name = filter.name, !name.isEmpty {
            return #Predicate<Entity> {
                $0.name.localizedStandardContains(name)
            }
        } else if let minCount = filter.minStationCount {
            return #Predicate<Entity> {
                $0.stationCount >= minCount
            }
        }
        return nil
    }

    override func sortDescriptors(from filter: FacetFilter) -> [SortDescriptor<Entity>]? {
        switch filter.orderBy {
        case .name:
            return [SortDescriptor(\Entity.name, order: filter.reverse ? .reverse : .forward)]
        case .stationCount:
            return [SortDescriptor(\Entity.stationCount, order: filter.reverse ? .reverse : .forward)]
        }
    }

    override func applyFilter(_ filter: FacetFilter, to results: inout [Entity]) throws {
        if let name = filter.name, !name.isEmpty {
            results = results.filter { $0.name.localizedStandardContains(name) }
        }

        if let minCount = filter.minStationCount {
            results = results.filter { $0.stationCount >= minCount }
        }

        switch filter.orderBy {
        case .name:
            results.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .stationCount:
            results.sort { $0.stationCount > $1.stationCount }
        }

        if filter.reverse {
            results.reverse()
        }
    }
}
