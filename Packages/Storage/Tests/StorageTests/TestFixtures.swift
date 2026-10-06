import Foundation
import Testing
import SwiftData
import StorageCore
@testable import Storage

/// DTO structs for testing that conform to the public protocols.
/// These replace the concrete implementation types which no longer conform
/// to the protocols (since SwiftData @Model classes cannot be Sendable).
/// Note: StationDTO is now defined in Models/StationEntity.swift

struct CountryDTO: CountryEntity {
    let name: String
    let iso31661: String
    let stationCount: Int
}

struct TagDTO: TagEntity {
    let name: String
    let stationCount: Int
}

struct LanguageDTO: LanguageEntity {
    let name: String
    let stationCount: Int
}

struct CodecDTO: CodecEntity {
    let name: String
    let stationCount: Int
}

extension StationEntityImpl {
    static func fixture(
        id: String = "station-1",
        name: String = "Test Station",
        url: String = "https://example.com/stream",
        homepage: String? = nil,
        favicon: String? = nil,
        tags: [String]? = nil,
        country: String = "US",
        state: String? = nil,
        language: String? = "English",
        votes: Int = 0,
        codec: String? = nil,
        bitrate: Int? = nil,
        lastCheckOk: Bool = true,
        changeCounter: Int = 0
    ) -> StationEntityImpl {
        StationEntityImpl(
            id: id,
            name: name,
            url: url,
            homepage: homepage,
            favicon: favicon,
            tags: tags,
            country: country,
            state: state,
            language: language,
            votes: votes,
            codec: codec,
            bitrate: bitrate,
            lastCheckOk: lastCheckOk,
            changeCounter: changeCounter
        )
    }
}

extension CountryEntityImpl {
    static func fixture(
        name: String = "United States",
        iso31661: String = "US",
        stationCount: Int = 100
    ) -> CountryEntityImpl {
        CountryEntityImpl(
            name: name,
            iso31661: iso31661,
            stationCount: stationCount
        )
    }
}

extension TagEntityImpl {
    static func fixture(
        name: String = "rock",
        stationCount: Int = 50
    ) -> TagEntityImpl {
        TagEntityImpl(
            name: name,
            stationCount: stationCount
        )
    }
}

extension LanguageEntityImpl {
    static func fixture(
        name: String = "English",
        stationCount: Int = 200
    ) -> LanguageEntityImpl {
        LanguageEntityImpl(
            name: name,
            stationCount: stationCount
        )
    }
}

extension CodecEntityImpl {
    static func fixture(
        name: String = "MP3",
        stationCount: Int = 300
    ) -> CodecEntityImpl {
        CodecEntityImpl(
            name: name,
            stationCount: stationCount
        )
    }
}

/// Test DTO fixtures
extension StationDTO {
    static func fixture(
        id: String = "station-1",
        name: String = "Test Station",
        url: String = "https://example.com/stream",
        homepage: String? = nil,
        favicon: String? = nil,
        tags: [String]? = nil,
        country: String = "US",
        state: String? = nil,
        language: String? = "English",
        votes: Int = 0,
        codec: String? = nil,
        bitrate: Int? = nil,
        lastCheckOk: Bool = true,
        lastCheckTime: Date? = nil,
        lastCheckTotal: Int = 0,
        lastCheckFailures: Int = 0,
        lastCheckDuration: Int = 0,
        lastCheckError: String? = nil,
        lastChangeTime: Date? = nil,
        changeCounter: Int = 0,
        creationTime: Date? = nil,
        urlResolved: String? = nil
    ) -> StationDTO {
        let impl = StationEntityImpl(
            id: id,
            name: name,
            url: url,
            homepage: homepage,
            favicon: favicon,
            tags: tags,
            country: country,
            state: state,
            language: language,
            votes: votes,
            codec: codec,
            bitrate: bitrate,
            lastCheckOk: lastCheckOk,
            lastCheckTime: lastCheckTime,
            lastCheckTotal: lastCheckTotal,
            lastCheckFailures: lastCheckFailures,
            lastCheckDuration: lastCheckDuration,
            lastCheckError: lastCheckError,
            lastChangeTime: lastChangeTime,
            changeCounter: changeCounter,
            creationTime: creationTime,
            urlResolved: urlResolved
        )
        return StationDTO.from(impl)
    }
}

extension CountryDTO {
    static func fixture(
        name: String = "United States",
        iso31661: String = "US",
        stationCount: Int = 100
    ) -> CountryDTO {
        CountryDTO(name: name, iso31661: iso31661, stationCount: stationCount)
    }
}

extension TagDTO {
    static func fixture(
        name: String = "rock",
        stationCount: Int = 50
    ) -> TagDTO {
        TagDTO(name: name, stationCount: stationCount)
    }
}

extension LanguageDTO {
    static func fixture(
        name: String = "English",
        stationCount: Int = 200
    ) -> LanguageDTO {
        LanguageDTO(name: name, stationCount: stationCount)
    }
}

extension CodecDTO {
    static func fixture(
        name: String = "MP3",
        stationCount: Int = 300
    ) -> CodecDTO {
        CodecDTO(name: name, stationCount: stationCount)
    }
}

extension Storage.DataStore {
    func rowCount<Entity: PersistentModel>(_ type: Entity.Type) throws -> Int {
        try container.mainContext.fetchCount(FetchDescriptor<Entity>())
    }
}

extension Storage.DataStore {
    /// In-memory store that owns its container, so tests never leak a persistent store.
    @MainActor
    static func makeInMemoryStore() throws -> Storage.DataStore {
        Storage.DataStore(modelContainer: try StorageContainer.create(isInMemory: true))
    }
}
