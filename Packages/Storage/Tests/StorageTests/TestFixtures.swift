import Foundation
import Testing
import SwiftData
@testable import Storage

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
