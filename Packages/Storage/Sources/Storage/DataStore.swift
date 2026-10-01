import Foundation
import SwiftData
import Combine

@MainActor
public final class DataStore {
    private let stations: any StationStorage
    private let countries: any CountryStorage
    private let tags: any TagStorage
    private let languages: any LanguageStorage
    private let codecs: any CodecStorage

    private var stationsPublisher: AnyPublisher<[any StationEntity], Never> {
        stations.stationsPublisher
    }

    private var countriesPublisher: AnyPublisher<[any CountryEntity], Never> {
        countries.countriesPublisher
    }

    private var tagsPublisher: AnyPublisher<[any TagEntity], Never> {
        tags.tagsPublisher
    }

    private var languagesPublisher: AnyPublisher<[any LanguageEntity], Never> {
        languages.languagesPublisher
    }

    private var codecsPublisher: AnyPublisher<[any CodecEntity], Never> {
        codecs.codecsPublisher
    }

    public static func create(di: DIContainer) -> DataStore {
        DataStore(di: di)
    }

    public init(di: DIContainer) {
        let context = di.modelContainer.mainContext
        self.stations = StationStorageImpl(modelContext: context)
        self.countries = CountryStorageImpl(modelContext: context)
        self.tags = TagStorageImpl(modelContext: context)
        self.languages = LanguageStorageImpl(modelContext: context)
        self.codecs = CodecStorageImpl(modelContext: context)
    }

    public func saveStations(_ stations: [some StationEntity]) throws {
        let entities = stations.map { StationEntityImpl.from($0) }
        try self.stations.save(entities)
    }

    public func stationsPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never> {
        stations.filteredPublisher(filter: filter)
    }

    public func saveCountries(_ countries: [some CountryEntity]) throws {
        let entities = countries.map { CountryEntityImpl.from($0) }
        try self.countries.save(entities)
    }

    public func countriesPublisher(filter: CountryFilter) -> AnyPublisher<[any CountryEntity], Never> {
        countries.filteredPublisher(filter: filter)
    }

    public func saveTags(_ tags: [some TagEntity]) throws {
        let entities = tags.map { TagEntityImpl.from($0) }
        try self.tags.save(entities)
    }

    public func tagsPublisher(filter: TagFilter) -> AnyPublisher<[any TagEntity], Never> {
        tags.filteredPublisher(filter: filter)
    }

    public func saveLanguages(_ languages: [some LanguageEntity]) throws {
        let entities = languages.map { LanguageEntityImpl.from($0) }
        try self.languages.save(entities)
    }

    public func languagesPublisher(filter: LanguageFilter) -> AnyPublisher<[any LanguageEntity], Never> {
        languages.filteredPublisher(filter: filter)
    }

    public func saveCodecs(_ codecs: [some CodecEntity]) throws {
        let entities = codecs.map { CodecEntityImpl.from($0) }
        try self.codecs.save(entities)
    }

    public func codecsPublisher(filter: CodecFilter) -> AnyPublisher<[any CodecEntity], Never> {
        codecs.filteredPublisher(filter: filter)
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
