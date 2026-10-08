import Foundation
import SwiftData

extension FacetOrderBy {
    func facetComesBefore<E: FacetEntity>(_ lhs: E, _ rhs: E) -> Bool {
        switch self {
        case .name: lhs.name < rhs.name
        case .stationCount: lhs.stationCount > rhs.stationCount
        }
    }

    func facetSortDescriptor<E: FacetEntity>(reverse: Bool) -> [SortDescriptor<E>]? {
        switch self {
        case .name:
            [SortDescriptor(\E.name, order: reverse ? .reverse : .forward)]
        case .stationCount:
            [SortDescriptor(\E.stationCount, order: reverse ? .forward : .reverse)]
        }
    }
}

private func facetPredicate<E: PersistentModel & FacetEntity>(_ filter: FacetFilter) -> Predicate<E>? {
    let name = filter.name ?? ""
    let minCount = filter.minStationCount ?? 0
    let hasName = !name.isEmpty
    let hasMinCount = filter.minStationCount != nil

    guard hasName || hasMinCount else { return nil }

    return #Predicate<E> { facet in
        (!hasName || facet.name.localizedStandardContains(name)) &&
        (!hasMinCount || facet.stationCount >= minCount)
    }
}

private func facetMatching<E: FacetEntity>(_ filter: FacetFilter, _ all: [E]) -> [E] {
    var results = all

    if let name = filter.name, !name.isEmpty {
        results = results.filter { $0.name.localizedStandardContains(name) }
    }

    if let minCount = filter.minStationCount {
        results = results.filter { $0.stationCount >= minCount }
    }

    return results
}

private func facetOrdered<E: FacetEntity>(_ filter: FacetFilter, _ entities: [E]) -> [E] {
    let sorted = entities.sorted { filter.orderBy.facetComesBefore($0, $1) }
    return filter.reverse ? sorted.reversed() : sorted
}

extension FilterStrategy where Entity: PersistentModel & FacetEntity, Filter == FacetFilter {
    static var facet: FilterStrategy {
        FilterStrategy(
            defaultSortDescriptors: [SortDescriptor(\Entity.name)],
            plan: facetPlan,
            postProcess: { _, _ in },
            matching: facetMatching,
            ordered: facetOrdered,
            windowed: { _, entities in entities }
        )
    }
}

private func facetPlan<E: PersistentModel & FacetEntity>(_ filter: FacetFilter) -> FetchPlan<E> {
    let predicate: Predicate<E>? = facetPredicate(filter)
    let sortDescriptors = filter.orderBy.facetSortDescriptor(reverse: filter.reverse)
        ?? [SortDescriptor(\E.name)]
    return FetchPlan(
        predicate: predicate,
        sortDescriptors: sortDescriptors,
        windowInSQLite: predicate != nil,
        offset: nil,
        limit: nil
    )
}
