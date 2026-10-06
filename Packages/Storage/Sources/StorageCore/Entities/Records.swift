import Foundation

// Concrete, persistence-free DTOs the storage layer accepts and publishes.
//
// The entity protocols define the contract; these structs are the convenient
// default implementation so consumers (app adapters, tests, previews) map
// their own models once instead of declaring a new conforming type per
// boundary. `DataStore` publishes `[any StationEntity]` etc., so existing
// protocol-based consumers are unaffected.

// MARK: - Stations

/// A radio station as a plain value. Optional check-counter fields default to
/// zero because the stored model is non-optional there; callers mapping from
/// the API decide how to fill gaps.
public struct StationRecord: StationEntity, Sendable, Hashable {
    public var id: String
    public var name: String
    public var url: String
    public var country: String
    public var homepage: String?
    public var favicon: String?
    public var tags: [String]?
    public var state: String?
    public var language: String?
    public var votes: Int
    public var codec: String?
    public var bitrate: Int?
    public var lastCheckOk: Bool
    public var lastCheckTime: Date?
    public var lastCheckTotal: Int
    public var lastCheckFailures: Int
    public var lastCheckDuration: Int
    public var lastCheckError: String?
    public var lastChangeTime: Date?
    public var changeCounter: Int
    public var creationTime: Date?
    public var urlResolved: String?

    public init(
        id: String,
        name: String,
        url: String,
        country: String,
        homepage: String? = nil,
        favicon: String? = nil,
        tags: [String]? = nil,
        state: String? = nil,
        language: String? = nil,
        votes: Int = 0,
        codec: String? = nil,
        bitrate: Int? = nil,
        lastCheckOk: Bool = false,
        lastCheckTime: Date? = nil,
        lastCheckTotal: Int = 0,
        lastCheckFailures: Int = 0,
        lastCheckDuration: Int = 0,
        lastCheckError: String? = nil,
        lastChangeTime: Date? = nil,
        changeCounter: Int = 0,
        creationTime: Date? = nil,
        urlResolved: String? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.country = country
        self.homepage = homepage
        self.favicon = favicon
        self.tags = tags
        self.state = state
        self.language = language
        self.votes = votes
        self.codec = codec
        self.bitrate = bitrate
        self.lastCheckOk = lastCheckOk
        self.lastCheckTime = lastCheckTime
        self.lastCheckTotal = lastCheckTotal
        self.lastCheckFailures = lastCheckFailures
        self.lastCheckDuration = lastCheckDuration
        self.lastCheckError = lastCheckError
        self.lastChangeTime = lastChangeTime
        self.changeCounter = changeCounter
        self.creationTime = creationTime
        self.urlResolved = urlResolved
    }
}

// MARK: - Facets

/// A country facet as a plain value.
public struct CountryRecord: CountryEntity, Sendable, Hashable {
    public var name: String
    public var iso31661: String
    public var stationCount: Int

    public init(name: String, iso31661: String, stationCount: Int = 0) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }
}

/// A tag facet as a plain value.
public struct TagRecord: TagEntity, Sendable, Hashable {
    public var name: String
    public var stationCount: Int

    public init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }
}

/// A language facet as a plain value.
public struct LanguageRecord: LanguageEntity, Sendable, Hashable {
    public var name: String
    public var stationCount: Int

    public init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }
}

/// A codec facet as a plain value.
public struct CodecRecord: CodecEntity, Sendable, Hashable {
    public var name: String
    public var stationCount: Int

    public init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }
}
