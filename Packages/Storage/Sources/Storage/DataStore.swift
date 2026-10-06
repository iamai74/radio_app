import Foundation
import SwiftData
import Combine
@_exported import StorageCore

/// Facade over the repositories. Saves run on a background `ModelContext`; only
/// the published results hop back to the main actor.
///
/// Every method is a one-line forward into a repository — mapping, filtering
/// and publication live there, so this type never grows logic as entities are
/// added. Conforms to the role-split protocols of `StorageCore`
/// (`StationWriting`, `FacetReading`, …) so consumers can depend on the
/// narrowest surface they need.
@MainActor
public final class DataStore: DataStoreProtocol {
    // `ModelContext` does not retain its container, so the container must stay
    // alive for as long as this store is used. Holding it here is what makes
    // `DataStore(modelContainer:)` safe for callers that don't keep their own
    // reference (previews, tests, `AppInitializer` locals).
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

    /// Container backing this store. Exposed so callers can hand the same
    /// container to SwiftUI views without keeping a duplicate reference.
    public var container: ModelContainer { modelContainer }

    // MARK: - StorageFailures

    /// Read failures from every repository, merged into one stream. Writes
    /// report failures by throwing; this is how a reader hears about them.
    public var failures: AnyPublisher<StorageError, Never> {
        Publishers.MergeMany(
            stations.failures,
            countries.failures,
            tags.failures,
            languages.failures,
            codecs.failures
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Stations

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

    public func deleteAllStations() async throws {
        try await stations.deleteAll()
    }

    // MARK: - Countries

    public func saveCountries(_ countries: [some CountryEntity]) async throws {
        try await self.countries.save(countries)
    }

    public func countriesPublisher(filter: FacetFilter) -> AnyPublisher<[any CountryEntity], Never> {
        self.countries.publisher(filter: filter)
            .map { $0 as [any CountryEntity] }
            .eraseToAnyPublisher()
    }

    public func countriesSequence(filter: FacetFilter) -> StorageSequence<any CountryEntity> {
        countries.sequence(filter: filter).map { $0 as [any CountryEntity] }
    }

    public func deleteAllCountries() async throws {
        try await countries.deleteAll()
    }

    // MARK: - Tags

    public func saveTags(_ tags: [some TagEntity]) async throws {
        try await self.tags.save(tags)
    }

    public func tagsPublisher(filter: FacetFilter) -> AnyPublisher<[any TagEntity], Never> {
        self.tags.publisher(filter: filter)
            .map { $0 as [any TagEntity] }
            .eraseToAnyPublisher()
    }

    public func tagsSequence(filter: FacetFilter) -> StorageSequence<any TagEntity> {
        tags.sequence(filter: filter).map { $0 as [any TagEntity] }
    }

    public func deleteAllTags() async throws {
        try await tags.deleteAll()
    }

    // MARK: - Languages

    public func saveLanguages(_ languages: [some LanguageEntity]) async throws {
        try await self.languages.save(languages)
    }

    public func languagesPublisher(filter: FacetFilter) -> AnyPublisher<[any LanguageEntity], Never> {
        self.languages.publisher(filter: filter)
            .map { $0 as [any LanguageEntity] }
            .eraseToAnyPublisher()
    }

    public func languagesSequence(filter: FacetFilter) -> StorageSequence<any LanguageEntity> {
        languages.sequence(filter: filter).map { $0 as [any LanguageEntity] }
    }

    public func deleteAllLanguages() async throws {
        try await languages.deleteAll()
    }

    // MARK: - Codecs

    public func saveCodecs(_ codecs: [some CodecEntity]) async throws {
        try await self.codecs.save(codecs)
    }

    public func codecsPublisher(filter: FacetFilter) -> AnyPublisher<[any CodecEntity], Never> {
        self.codecs.publisher(filter: filter)
            .map { $0 as [any CodecEntity] }
            .eraseToAnyPublisher()
    }

    public func codecsSequence(filter: FacetFilter) -> StorageSequence<any CodecEntity> {
        codecs.sequence(filter: filter).map { $0 as [any CodecEntity] }
    }

    public func deleteAllCodecs() async throws {
        try await codecs.deleteAll()
    }
}
