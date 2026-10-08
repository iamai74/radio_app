import Foundation
import SwiftData

extension StationOrderBy {
    func stationComesBefore(_ lhs: StationEntityImpl, _ rhs: StationEntityImpl) -> Bool {
        switch self {
        case .name: lhs.name < rhs.name
        case .votes: lhs.votes > rhs.votes
        case .bitrate: (lhs.bitrate ?? .min) > (rhs.bitrate ?? .min)
        case .changeCounter: lhs.changeCounter > rhs.changeCounter
        case .lastCheckOk: lhs.lastCheckOk && !rhs.lastCheckOk
        }
    }

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
    results = stationMatching(filter, results)
    if filter.orderBy == .lastCheckOk {
        results = stationOrdered(filter, results)
    }
}

extension FilterStrategy where Entity == StationEntityImpl, Filter == StationFilter {
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
