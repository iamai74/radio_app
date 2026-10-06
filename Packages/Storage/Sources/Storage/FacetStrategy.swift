import Foundation
import SwiftData

// MARK: - Ordering (single source of truth)

extension FacetFilter.FacetOrderBy {
    /// Forward order for the in-memory path; `facetSortDescriptor(reverse:)`
    /// derives the SQLite `SortDescriptor` from the same definition.
    func facetComesBefore<E: FacetEntity>(_ lhs: E, _ rhs: E) -> Bool {
        switch self {
        case .name: lhs.name < rhs.name
        case .stationCount: lhs.stationCount > rhs.stationCount
        }
    }

    /// SQLite pushdown for facet ordering. `.stationCount` is "largest first"
    /// by default, so the descriptor uses descending order for the forward case.
    func facetSortDescriptor<E: FacetEntity>(reverse: Bool) -> [SortDescriptor<E>]? {
        switch self {
        case .name:
            [SortDescriptor(\E.name, order: reverse ? .reverse : .forward)]
        case .stationCount:
            [SortDescriptor(\E.stationCount, order: reverse ? .forward : .reverse)]
        }
    }
}

// MARK: - Filtering

/// SQLite-level facet filter: name + minimum station count in one predicate,
/// one clause per dimension (no branch per subset of fields).
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

// MARK: - Strategy

extension FilterStrategy where Entity: PersistentModel & FacetEntity, Filter == FacetFilter {
    /// Facets filter and order fully in SQLite; nothing needs post-processing,
    /// so `requiresPostProcessing` stays false and SQLite owns the window.
    static var facet: FilterStrategy {
        FilterStrategy(
            defaultSortDescriptors: [SortDescriptor(\Entity.name)],
            predicate: facetPredicate,
            sortDescriptors: { filter in
                filter.orderBy.facetSortDescriptor(reverse: filter.reverse)
            },
            fetchOffset: { _ in nil },
            fetchLimit: { _ in nil },
            requiresPostProcessing: { _ in false },
            postProcess: { _, _ in },
            matching: facetMatching,
            ordered: facetOrdered,
            windowed: { _, entities in entities }
        )
    }
}
