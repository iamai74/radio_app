import Foundation
import Combine

// The read/write surface is split by role so consumers can depend on the
// narrowest protocol they need: a syncing service takes a writer, a view takes
// a reader, and neither sees the other's methods. `DataStore` is the
// SwiftData-backed implementation of the aggregate.

/// Read surface for stations.
@MainActor
public protocol StationReading: AnyObject {
    func stationsPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never>
    func stationsSequence(filter: StationFilter) -> StorageSequence<any StationEntity>
}

/// Write surface for stations.
@MainActor
public protocol StationWriting: AnyObject {
    func saveStations(_ stations: [some StationEntity]) async throws
    func deleteAllStations() async throws
}

/// Read surface for the four facet kinds (country, tag, language, codec).
@MainActor
public protocol FacetReading: AnyObject {
    func countriesPublisher(filter: FacetFilter) -> AnyPublisher<[any CountryEntity], Never>
    func tagsPublisher(filter: FacetFilter) -> AnyPublisher<[any TagEntity], Never>
    func languagesPublisher(filter: FacetFilter) -> AnyPublisher<[any LanguageEntity], Never>
    func codecsPublisher(filter: FacetFilter) -> AnyPublisher<[any CodecEntity], Never>

    func countriesSequence(filter: FacetFilter) -> StorageSequence<any CountryEntity>
    func tagsSequence(filter: FacetFilter) -> StorageSequence<any TagEntity>
    func languagesSequence(filter: FacetFilter) -> StorageSequence<any LanguageEntity>
    func codecsSequence(filter: FacetFilter) -> StorageSequence<any CodecEntity>
}

/// Write surface for the four facet kinds.
@MainActor
public protocol FacetWriting: AnyObject {
    func saveCountries(_ countries: [some CountryEntity]) async throws
    func saveTags(_ tags: [some TagEntity]) async throws
    func saveLanguages(_ languages: [some LanguageEntity]) async throws
    func saveCodecs(_ codecs: [some CodecEntity]) async throws

    func deleteAllCountries() async throws
    func deleteAllTags() async throws
    func deleteAllLanguages() async throws
    func deleteAllCodecs() async throws
}

/// Read failures that are not part of a write's `throws` surface.
///
/// Writes report failures by throwing; reads publish on this stream so a
/// caller can tell "the store is empty" apart from "the fetch broke" instead
/// of receiving a silent empty array.
@MainActor
public protocol StorageFailures: AnyObject {
    var failures: AnyPublisher<StorageError, Never> { get }
}

/// Aggregate surface: everything `Storage.DataStore` supports, with no
/// persistence types in sight.
///
/// Save methods stay generic so callers pass their concrete model type and pay
/// nothing for an existential array; the DTO protocols do the constraining.
@MainActor
public protocol DataStoreProtocol: StationReading, StationWriting, FacetReading, FacetWriting, StorageFailures {}
