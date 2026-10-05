import Foundation

/// Read/write surface consumers code against, with no persistence types in
/// sight. `Storage.DataStore` is the SwiftData-backed implementation.
///
/// Save methods stay generic so callers pass their concrete model type and pay
/// nothing for an existential array; the DTO protocols do the constraining.
@MainActor
public protocol DataStoreProtocol: AnyObject {
    func saveStations(_ stations: [some StationEntity]) async throws
    func saveCountries(_ countries: [some CountryEntity]) async throws
    func saveTags(_ tags: [some TagEntity]) async throws
    func saveLanguages(_ languages: [some LanguageEntity]) async throws
    func saveCodecs(_ codecs: [some CodecEntity]) async throws

    func deleteAllStations() async throws
    func deleteAllCountries() async throws
    func deleteAllTags() async throws
    func deleteAllLanguages() async throws
    func deleteAllCodecs() async throws
}
