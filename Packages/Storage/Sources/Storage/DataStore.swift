import Foundation
import SwiftData
import Combine
@_exported import StorageCore

/// Facade over the stores. Saves run on a background `ModelContext`; only the
/// published results hop back to the main actor.
@MainActor
public final class DataStore: DataStoreProtocol {
    // `ModelContext` does not retain its container, so the container must stay
    // alive for as long as this store is used. Holding it here is what makes
    // `DataStore(modelContainer:)` safe for callers that don't keep their own
    // reference (previews, tests, `AppInitializer` locals).
    private let modelContainer: ModelContainer
    private let stations: StationStore
    private let countries: FacetStore<CountryEntityImpl>
    private let tags: FacetStore<TagEntityImpl>
    private let languages: FacetStore<LanguageEntityImpl>
    private let codecs: FacetStore<CodecEntityImpl>

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = modelContainer.mainContext
        self.stations = StationStore(modelContext: context)
        self.countries = FacetStore<CountryEntityImpl>(modelContext: context)
        self.tags = FacetStore<TagEntityImpl>(modelContext: context)
        self.languages = FacetStore<LanguageEntityImpl>(modelContext: context)
        self.codecs = FacetStore<CodecEntityImpl>(modelContext: context)
    }

    /// Container backing this store. Exposed so callers can hand the same
    /// container to SwiftUI views without keeping a duplicate reference.
    public var container: ModelContainer { modelContainer }

    public func saveStations(_ stations: [some StationEntity]) async throws {
        try await self.stations.save(stations)
    }

    public func stationsPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never> {
        stations.publisher(filter: filter)
            .map { $0 as [any StationEntity] }
            .eraseToAnyPublisher()
    }

    public func stationsSequence(filter: StationFilter) -> StorageSequence<any StationEntity> {
        stations.sequence(filter: filter).map { $0 as [any StationEntity] }
    }

    public func saveCountries(_ countries: [some CountryEntity]) async throws {
        try await self.countries.save(countries.map { CountryEntityImpl.from($0) })
    }

    public func countriesPublisher(filter: CountryFilter) -> AnyPublisher<[any CountryEntity], Never> {
        self.countries.publisher(filter: filter)
            .map { $0 as [any CountryEntity] }
            .eraseToAnyPublisher()
    }

    public func countriesSequence(filter: CountryFilter) -> StorageSequence<any CountryEntity> {
        countries.sequence(filter: filter).map { $0 as [any CountryEntity] }
    }

    public func saveTags(_ tags: [some TagEntity]) async throws {
        try await self.tags.save(tags.map { TagEntityImpl.from($0) })
    }

    public func tagsPublisher(filter: TagFilter) -> AnyPublisher<[any TagEntity], Never> {
        self.tags.publisher(filter: filter)
            .map { $0 as [any TagEntity] }
            .eraseToAnyPublisher()
    }

    public func tagsSequence(filter: TagFilter) -> StorageSequence<any TagEntity> {
        tags.sequence(filter: filter).map { $0 as [any TagEntity] }
    }

    public func saveLanguages(_ languages: [some LanguageEntity]) async throws {
        try await self.languages.save(languages.map { LanguageEntityImpl.from($0) })
    }

    public func languagesPublisher(filter: LanguageFilter) -> AnyPublisher<[any LanguageEntity], Never> {
        self.languages.publisher(filter: filter)
            .map { $0 as [any LanguageEntity] }
            .eraseToAnyPublisher()
    }

    public func languagesSequence(filter: LanguageFilter) -> StorageSequence<any LanguageEntity> {
        languages.sequence(filter: filter).map { $0 as [any LanguageEntity] }
    }

    public func saveCodecs(_ codecs: [some CodecEntity]) async throws {
        try await self.codecs.save(codecs.map { CodecEntityImpl.from($0) })
    }

    public func codecsPublisher(filter: CodecFilter) -> AnyPublisher<[any CodecEntity], Never> {
        self.codecs.publisher(filter: filter)
            .map { $0 as [any CodecEntity] }
            .eraseToAnyPublisher()
    }

    public func codecsSequence(filter: CodecFilter) -> StorageSequence<any CodecEntity> {
        codecs.sequence(filter: filter).map { $0 as [any CodecEntity] }
    }

    public func deleteAllStations() async throws {
        try await stations.deleteAll()
    }

    public func deleteAllCountries() async throws {
        try await countries.deleteAll()
    }

    public func deleteAllTags() async throws {
        try await tags.deleteAll()
    }

    public func deleteAllLanguages() async throws {
        try await languages.deleteAll()
    }

    public func deleteAllCodecs() async throws {
        try await codecs.deleteAll()
    }
}
