import Foundation
import SwiftData
import Combine

@MainActor
public final class DataStore: DataStoreProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let backgroundStore: BackgroundStore
    private let _stationQueries: StationQueries
    private let _facetQueries: FacetQueries

    private let stations: StationRepository
    private let countries: FacetRepository<CountryEntityImpl, CountryEntity>
    private let tags: FacetRepository<TagEntityImpl, TagEntity>
    private let languages: FacetRepository<LanguageEntityImpl, LanguageEntity>
    private let codecs: FacetRepository<CodecEntityImpl, CodecEntity>

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        self.backgroundStore = BackgroundStore(modelContainer: modelContainer)
        self._stationQueries = StationQueries(context: modelContext)
        self._facetQueries = FacetQueries(context: modelContext)

        self.stations = StationRepository(modelContext: modelContext)
        self.countries = FacetRepository(modelContext: modelContext)
        self.tags = FacetRepository(modelContext: modelContext)
        self.languages = FacetRepository(modelContext: modelContext)
        self.codecs = FacetRepository(modelContext: modelContext)
    }

    public var container: ModelContainer { modelContainer }
    public var context: ModelContext { modelContext }

    public var stationQueries: StationQueries { _stationQueries }
    public var facetQueries: FacetQueries { _facetQueries }

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
        try await backgroundStore.saveStations(stations.map { $0 as any StationEntity })
        self.stations.reload()
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
        try await backgroundStore.deleteAllStations()
        stations.reload()
    }

    public func saveCountries(_ countries: [some CountryEntity]) async throws {
        try await backgroundStore.saveCountries(countries.map { $0 as any CountryEntity })
        self.countries.reload()
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
        try await backgroundStore.deleteAllCountries()
        countries.reload()
    }

    public func saveTags(_ tags: [some TagEntity]) async throws {
        try await backgroundStore.saveTags(tags.map { $0 as any TagEntity })
        self.tags.reload()
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
        try await backgroundStore.deleteAllTags()
        tags.reload()
    }

    public func saveLanguages(_ languages: [some LanguageEntity]) async throws {
        try await backgroundStore.saveLanguages(languages.map { $0 as any LanguageEntity })
        self.languages.reload()
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
        try await backgroundStore.deleteAllLanguages()
        languages.reload()
    }

    public func saveCodecs(_ codecs: [some CodecEntity]) async throws {
        try await backgroundStore.saveCodecs(codecs.map { $0 as any CodecEntity })
        self.codecs.reload()
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
        try await backgroundStore.deleteAllCodecs()
        codecs.reload()
    }

    public func bulkImportStations(_ stations: [some StationEntity]) async throws {
        try await backgroundStore.bulkImportStations(stations.map { $0 as any StationEntity })
        self.stations.reload()
    }
}
