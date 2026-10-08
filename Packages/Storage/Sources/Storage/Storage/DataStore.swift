import Foundation
import SwiftData
import Combine
import Storage

@MainActor
public final class DataStore: DataStoreProtocol {
    private let modelContainer: ModelContainer
    private let stations: StationRepository
    private let countries: FacetRepository<CountryEntityImpl, CountryEntity>
    private let tags: FacetRepository<TagEntityImpl, TagEntity>
    private let languages: FacetRepository<LanguageEntityImpl, LanguageEntity>
    private let codecs: FacetRepository<CodecEntityImpl, CodecEntity>

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = modelContainer.mainContext
        self.stations = StationRepository(modelContext: context)
        self.countries = FacetRepository(modelContext: context)
        self.tags = FacetRepository(modelContext: context)
        self.languages = FacetRepository(modelContext: context)
        self.codecs = FacetRepository(modelContext: context)
    }

    public var container: ModelContainer { modelContainer }

    public static func makeInMemoryStore() throws -> DataStore {
        DataStore(modelContainer: try StorageContainer.create(isInMemory: true))
    }

    public func rowCount<Entity: PersistentModel>(_ type: Entity.Type) throws -> Int {
        try container.mainContext.fetchCount(FetchDescriptor<Entity>())
    }

    public var failures: AnyPublisher<StorageError, Never> {
        Publishers.MergeMany(
            stations.failures,
            countries.failures,
            tags.failures,
            languages.failures,
            codecs.failures
        ).eraseToAnyPublisher()
    }

    public var cachedFilterCount: Int {
        stations.cachedFilterCount
            + countries.cachedFilterCount
            + tags.cachedFilterCount
            + languages.cachedFilterCount
            + codecs.cachedFilterCount
    }

    public func saveStations(_ stations: [some StationEntity]) async throws {
        try await self.stations.save(stations)
    }

    public func stationsPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never> {
        stations.publisher(filter: filter)
            .map { $0 as [any StationEntity] }
            .eraseToAnyPublisher()
    }

    public func stationsSequence(filter: StationFilter) -> StorageSequence<any StationEntity> {
        stations.sequence(filter: filter)
            .map { $0 as [any StationEntity] }
    }

    public func deleteAllStations() async throws {
        try await stations.deleteAll()
    }

    public func saveCountries(_ countries: [some CountryEntity]) async throws {
        try await self.countries.save(countries)
    }

    public func countriesPublisher(filter: FacetFilter) -> AnyPublisher<[any CountryEntity], Never> {
        self.countries.publisher(filter: filter)
            .map { $0 as [any CountryEntity] }
            .eraseToAnyPublisher()
    }

    public func countriesSequence(filter: FacetFilter) -> StorageSequence<any CountryEntity> {
        countries.sequence(filter: filter)
            .map { $0 as [any CountryEntity] }
    }

    public func deleteAllCountries() async throws {
        try await countries.deleteAll()
    }

    public func saveTags(_ tags: [some TagEntity]) async throws {
        try await self.tags.save(tags)
    }

    public func tagsPublisher(filter: FacetFilter) -> AnyPublisher<[any TagEntity], Never> {
        self.tags.publisher(filter: filter)
            .map { $0 as [any TagEntity] }
            .eraseToAnyPublisher()
    }

    public func tagsSequence(filter: FacetFilter) -> StorageSequence<any TagEntity> {
        tags.sequence(filter: filter)
            .map { $0 as [any TagEntity] }
    }

    public func deleteAllTags() async throws {
        try await tags.deleteAll()
    }

    public func saveLanguages(_ languages: [some LanguageEntity]) async throws {
        try await self.languages.save(languages)
    }

    public func languagesPublisher(filter: FacetFilter) -> AnyPublisher<[any LanguageEntity], Never> {
        self.languages.publisher(filter: filter)
            .map { $0 as [any LanguageEntity] }
            .eraseToAnyPublisher()
    }

    public func languagesSequence(filter: FacetFilter) -> StorageSequence<any LanguageEntity> {
        languages.sequence(filter: filter)
            .map { $0 as [any LanguageEntity] }
    }

    public func deleteAllLanguages() async throws {
        try await languages.deleteAll()
    }

    public func saveCodecs(_ codecs: [some CodecEntity]) async throws {
        try await self.codecs.save(codecs)
    }

    public func codecsPublisher(filter: FacetFilter) -> AnyPublisher<[any CodecEntity], Never> {
        self.codecs.publisher(filter: filter)
            .map { $0 as [any CodecEntity] }
            .eraseToAnyPublisher()
    }

    public func codecsSequence(filter: FacetFilter) -> StorageSequence<any CodecEntity> {
        codecs.sequence(filter: filter)
            .map { $0 as [any CodecEntity] }
    }

    public func deleteAllCodecs() async throws {
        try await codecs.deleteAll()
    }
}
