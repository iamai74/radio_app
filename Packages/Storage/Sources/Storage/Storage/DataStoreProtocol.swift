import Foundation
import SwiftData
import Combine

@MainActor
public protocol StationWriting: AnyObject {
    func saveStations(_ stations: [some StationEntity]) async throws
    func deleteAllStations() async throws
}

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

@MainActor
public protocol StorageFailures: AnyObject {
    var failures: AnyPublisher<StorageError, Never> { get }
}

@MainActor
public protocol StationReading: AnyObject {
    func stationsPublisher(filter: StationFilter) -> AnyPublisher<[any StationEntity], Never>
    func stationsSequence(filter: StationFilter) -> StorageSequence<any StationEntity>
}

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

@MainActor
public protocol DataStoreProtocol: StationReading, StationWriting, FacetReading, FacetWriting, StorageFailures {
    var container: ModelContainer { get }
}
