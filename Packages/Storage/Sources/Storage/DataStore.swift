import Foundation
import SwiftData
import Combine

@MainActor
public final class DataStore {
    private let stations: StationStore
    private let countries: FacetStore<CountryEntityImpl>
    private let tags: FacetStore<TagEntityImpl>
    private let languages: FacetStore<LanguageEntityImpl>
    private let codecs: FacetStore<CodecEntityImpl>

    public static func create(di: DIContainer) -> DataStore {
        DataStore(di: di)
    }

    public init(di: DIContainer) {
        let context = di.modelContainer.mainContext
        self.stations = StationStore(modelContext: context)
        self.countries = FacetStore<CountryEntityImpl>(modelContext: context)
        self.tags = FacetStore<TagEntityImpl>(modelContext: context)
        self.languages = FacetStore<LanguageEntityImpl>(modelContext: context)
        self.codecs = FacetStore<CodecEntityImpl>(modelContext: context)
    }

    public func saveStations(_ stations: [some StationEntity]) throws {
        try self.stations.save(stations)
    }

    public func stationsPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never> {
        stations.publisher(filter: filter)
    }

    public func saveCountries(_ countries: [some CountryEntity]) throws {
        let entities = countries.map { CountryEntityImpl.from($0) }
        try self.countries.save(entities)
    }

    public func countriesPublisher(filter: CountryFilter) -> AnyPublisher<[any CountryEntity], Never> {
        self.countries.publisher(filter: filter)
            .map { $0 as [any CountryEntity] }
            .eraseToAnyPublisher()
    }

    public func saveTags(_ tags: [some TagEntity]) throws {
        let entities = tags.map { TagEntityImpl.from($0) }
        try self.tags.save(entities)
    }

    public func tagsPublisher(filter: TagFilter) -> AnyPublisher<[any TagEntity], Never> {
        self.tags.publisher(filter: filter)
            .map { $0 as [any TagEntity] }
            .eraseToAnyPublisher()
    }

    public func saveLanguages(_ languages: [some LanguageEntity]) throws {
        let entities = languages.map { LanguageEntityImpl.from($0) }
        try self.languages.save(entities)
    }

    public func languagesPublisher(filter: LanguageFilter) -> AnyPublisher<[any LanguageEntity], Never> {
        self.languages.publisher(filter: filter)
            .map { $0 as [any LanguageEntity] }
            .eraseToAnyPublisher()
    }

    public func saveCodecs(_ codecs: [some CodecEntity]) throws {
        let entities = codecs.map { CodecEntityImpl.from($0) }
        try self.codecs.save(entities)
    }

    public func codecsPublisher(filter: CodecFilter) -> AnyPublisher<[any CodecEntity], Never> {
        self.codecs.publisher(filter: filter)
            .map { $0 as [any CodecEntity] }
            .eraseToAnyPublisher()
    }

    public func deleteAllStations() throws {
        try stations.deleteAll()
    }

    public func deleteAllCountries() throws {
        try countries.deleteAll()
    }

    public func deleteAllTags() throws {
        try tags.deleteAll()
    }

    public func deleteAllLanguages() throws {
        try languages.deleteAll()
    }

    public func deleteAllCodecs() throws {
        try codecs.deleteAll()
    }
}
