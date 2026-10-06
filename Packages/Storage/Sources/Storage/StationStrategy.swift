import Foundation
import SwiftData

// MARK: - Ordering (single source of truth)

extension StationFilter.StationOrderBy {
    /// Forward order for the in-memory path.
    ///
    /// Each case defines its direction once here; `stationSortDescriptor(reverse:)`
    /// derives the SQLite `SortDescriptor` from the same definition, so the
    /// pushdown and in-memory paths cannot disagree on direction or collation.
    func stationComesBefore(_ lhs: StationEntityImpl, _ rhs: StationEntityImpl) -> Bool {
        switch self {
        // `<` mirrors the default `SortDescriptor(\.name)` / SQLite BINARY collation;
        // `localizedCompare` would order differently from what SQLite returns.
        case .name: lhs.name < rhs.name
        case .votes: lhs.votes > rhs.votes
        case .bitrate: (lhs.bitrate ?? .min) > (rhs.bitrate ?? .min)
        case .changeCounter: lhs.changeCounter > rhs.changeCounter
        case .lastCheckOk: lhs.lastCheckOk && !rhs.lastCheckOk
        }
    }

    /// SQLite pushdown for this ordering; `nil` when SQLite cannot express it,
    /// which routes the ordering through `postProcess` instead.
    func stationSortDescriptor(reverse: Bool) -> SortDescriptor<StationEntityImpl>? {
        switch self {
        case .name:
            SortDescriptor(\StationEntityImpl.name, order: reverse ? .reverse : .forward)
        case .votes:
            SortDescriptor(\StationEntityImpl.votes, order: reverse ? .forward : .reverse)
        case .bitrate:
            SortDescriptor(\StationEntityImpl.bitrate, order: reverse ? .forward : .reverse)
        case .changeCounter:
            SortDescriptor(\StationEntityImpl.changeCounter, order: reverse ? .forward : .reverse)
        case .lastCheckOk:
            nil
        }
    }
}

// MARK: - Filtering

/// SQLite-level station filter: name/country/language in one predicate.
///
/// A single flag-guarded `#Predicate` replaces the previous 8-branch
/// enumeration of every subset of the three optional fields — each dimension
/// contributes exactly one clause and new fields cannot add combinatorics.
private func stationPredicate(_ filter: StationFilter) -> Predicate<StationEntityImpl>? {
    let name = filter.name ?? ""
    let country = filter.country ?? ""
    let language = filter.language ?? ""
    let hasName = !name.isEmpty
    let hasCountry = filter.country != nil
    let hasLanguage = filter.language != nil

    guard hasName || hasCountry || hasLanguage else { return nil }

    return #Predicate<StationEntityImpl> { station in
        (!hasName || station.name.localizedStandardContains(name)) &&
        (!hasCountry || station.country == country) &&
        (!hasLanguage || station.language == language)
    }
}

/// In-memory matching. Mirrors `stationPredicate` and additionally covers
/// `tag`, which SQLite cannot express. Applying it to predicate results is
/// idempotent, which is what lets `postProcess` reuse it unchanged.
private func stationMatching(_ filter: StationFilter, _ all: [StationEntityImpl]) -> [StationEntityImpl] {
    var results = all

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

    return results
}

private func stationOrdered(_ filter: StationFilter, _ entities: [StationEntityImpl]) -> [StationEntityImpl] {
    let sorted = entities.sorted { filter.orderBy.stationComesBefore($0, $1) }
    return filter.reverse ? sorted.reversed() : sorted
}

private func stationWindowed(_ filter: StationFilter, _ entities: [StationEntityImpl]) -> [StationEntityImpl] {
    var results = entities

    if let offset = filter.offset, offset > 0 {
        results = Array(results.dropFirst(offset))
    }

    if let limit = filter.limit, limit > 0 {
        results = Array(results.prefix(limit))
    }

    return results
}

// MARK: - Strategy

extension FilterStrategy where Entity == StationEntityImpl, Filter == StationFilter {
    /// Pushes name/country/language + ordering into SQLite; `tag` matching and
    /// `.lastCheckOk` ordering run in memory after the fetch.
    ///
    /// The SQLite/in-memory split is decided exactly once, here: both the plan
    /// (window placement, predicate presence) and `postProcess` derive from
    /// `stationRequiresInMemory`, so they cannot drift apart.
    static var station: FilterStrategy {
        FilterStrategy(
            defaultSortDescriptors: [SortDescriptor(\StationEntityImpl.name)],
            plan: stationPlan,
            postProcess: stationPostProcess,
            matching: stationMatching,
            ordered: stationOrdered,
            windowed: stationWindowed
        )
    }
}

/// True when part of the filter cannot be expressed in a SwiftData
/// `#Predicate` — `tag` matching, `.lastCheckOk` ordering — so post-processing
/// and the offset/limit window have to run in memory after the fetch.
private func stationRequiresInMemory(_ filter: StationFilter) -> Bool {
    (filter.tag?.isEmpty == false) || filter.orderBy == .lastCheckOk
}

private func stationPlan(_ filter: StationFilter) -> FetchPlan<StationEntityImpl> {
    let predicate = stationPredicate(filter)
    let requiresInMemory = stationRequiresInMemory(filter)
    let windowInSQLite = predicate != nil && !requiresInMemory
    let sortDescriptors = filter.orderBy.stationSortDescriptor(reverse: filter.reverse).map { [$0] }
        ?? [SortDescriptor(\StationEntityImpl.name)]
    return FetchPlan(
        predicate: predicate,
        sortDescriptors: sortDescriptors,
        windowInSQLite: windowInSQLite,
        offset: windowInSQLite ? filter.offset : nil,
        limit: windowInSQLite ? filter.limit : nil
    )
}

private func stationPostProcess(_ filter: StationFilter, _ results: inout [StationEntityImpl]) {
    // Re-running `matching` is idempotent for the dimensions SQLite
    // already applied; it is the only place tag filtering lives.
    results = stationMatching(filter, results)
    if filter.orderBy == .lastCheckOk {
        results = stationOrdered(filter, results)
    }
}
