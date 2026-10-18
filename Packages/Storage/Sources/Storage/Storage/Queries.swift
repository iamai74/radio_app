import Foundation
import SwiftData
import SwiftUI

@MainActor
public struct StationQueries {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func allStations(
        filter: StationFilter = .empty,
        sortBy: StationOrderBy = .name,
        ascending: Bool = true,
        limit: Int? = nil
    ) throws -> [any StationEntity] {
        var descriptor = FetchDescriptor<StationEntityImpl>(
            sortBy: [SortDescriptor(\StationEntityImpl.name, order: ascending ? .forward : .reverse)]
        )

        if let name = filter.name, !name.isEmpty {
            descriptor.predicate = #Predicate { $0.name.localizedStandardContains(name) }
        }
        if let country = filter.country {
            descriptor.predicate = #Predicate { $0.country == country }
        }
        if let language = filter.language {
            descriptor.predicate = #Predicate { $0.language == language }
        }
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
        if let offset = filter.offset, offset > 0 {
            descriptor.fetchOffset = offset
        }

        let results = try context.fetch(descriptor)
        return results.map { $0.toDTO() }
    }

    public func station(byID id: String) throws -> (any StationEntity)? {
        let descriptor = FetchDescriptor<StationEntityImpl>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first?.toDTO()
    }
}

@MainActor
public struct FacetQueries {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func countries(
        filter: FacetFilter = .empty,
        sortBy: FacetOrderBy = .name,
        ascending: Bool = true,
        limit: Int? = nil
    ) throws -> [any CountryEntity] {
        var descriptor = FetchDescriptor<CountryEntityImpl>(
            sortBy: [SortDescriptor(\CountryEntityImpl.name, order: ascending ? .forward : .reverse)]
        )
        if let name = filter.name, !name.isEmpty {
            descriptor.predicate = #Predicate { $0.name.localizedStandardContains(name) }
        }
        if let minCount = filter.minStationCount {
            descriptor.predicate = #Predicate { $0.stationCount >= minCount }
        }
        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        let results = try context.fetch(descriptor)
        return results.map { $0.toDTO() }
    }

    public func tags(
        filter: FacetFilter = .empty,
        sortBy: FacetOrderBy = .name,
        ascending: Bool = true,
        limit: Int? = nil
    ) throws -> [any TagEntity] {
        var descriptor = FetchDescriptor<TagEntityImpl>(
            sortBy: [SortDescriptor(\TagEntityImpl.name, order: ascending ? .forward : .reverse)]
        )
        if let name = filter.name, !name.isEmpty {
            descriptor.predicate = #Predicate { $0.name.localizedStandardContains(name) }
        }
        if let minCount = filter.minStationCount {
            descriptor.predicate = #Predicate { $0.stationCount >= minCount }
        }
        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        let results = try context.fetch(descriptor)
        return results.map { $0.toDTO() }
    }

    public func languages(
        filter: FacetFilter = .empty,
        sortBy: FacetOrderBy = .name,
        ascending: Bool = true,
        limit: Int? = nil
    ) throws -> [any LanguageEntity] {
        var descriptor = FetchDescriptor<LanguageEntityImpl>(
            sortBy: [SortDescriptor(\LanguageEntityImpl.name, order: ascending ? .forward : .reverse)]
        )
        if let name = filter.name, !name.isEmpty {
            descriptor.predicate = #Predicate { $0.name.localizedStandardContains(name) }
        }
        if let minCount = filter.minStationCount {
            descriptor.predicate = #Predicate { $0.stationCount >= minCount }
        }
        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        let results = try context.fetch(descriptor)
        return results.map { $0.toDTO() }
    }

    public func codecs(
        filter: FacetFilter = .empty,
        sortBy: FacetOrderBy = .name,
        ascending: Bool = true,
        limit: Int? = nil
    ) throws -> [any CodecEntity] {
        var descriptor = FetchDescriptor<CodecEntityImpl>(
            sortBy: [SortDescriptor(\CodecEntityImpl.name, order: ascending ? .forward : .reverse)]
        )
        if let name = filter.name, !name.isEmpty {
            descriptor.predicate = #Predicate { $0.name.localizedStandardContains(name) }
        }
        if let minCount = filter.minStationCount {
            descriptor.predicate = #Predicate { $0.stationCount >= minCount }
        }
        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        let results = try context.fetch(descriptor)
        return results.map { $0.toDTO() }
    }
}
