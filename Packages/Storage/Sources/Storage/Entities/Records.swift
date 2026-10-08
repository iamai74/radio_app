import Foundation

public protocol StationEntity: Sendable, Hashable {
    var id: String { get }
    var name: String { get }
    var url: String { get }
    var homepage: String? { get }
    var favicon: String? { get }
    var tags: [String]? { get }
    var country: String { get }
    var state: String? { get }
    var language: String? { get }
    var votes: Int { get }
    var codec: String? { get }
    var bitrate: Int? { get }
    var lastCheckOk: Bool { get }
    var lastCheckTime: Date? { get }
    var lastCheckTotal: Int { get }
    var lastCheckFailures: Int { get }
    var lastCheckDuration: Int { get }
    var lastCheckError: String? { get }
    var lastChangeTime: Date? { get }
    var changeCounter: Int { get }
    var creationTime: Date? { get }
    var urlResolved: String? { get }
}

public protocol CountryEntity: Sendable, Hashable {
    var name: String { get }
    var iso31661: String { get }
    var stationCount: Int { get }
}

public protocol TagEntity: Sendable, Hashable {
    var name: String { get }
    var stationCount: Int { get }
}

public protocol LanguageEntity: Sendable, Hashable {
    var name: String { get }
    var stationCount: Int { get }
}

public protocol CodecEntity: Sendable, Hashable {
    var name: String { get }
    var stationCount: Int { get }
}

public struct StationRecord: StationEntity {
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

public struct CountryRecord: CountryEntity {
    public var name: String
    public var iso31661: String
    public var stationCount: Int

    public init(name: String, iso31661: String, stationCount: Int = 0) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }
}

public struct TagRecord: TagEntity {
    public var name: String
    public var stationCount: Int

    public init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }
}

public struct LanguageRecord: LanguageEntity {
    public var name: String
    public var stationCount: Int

    public init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }
}

public struct CodecRecord: CodecEntity {
    public var name: String
    public var stationCount: Int

    public init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }
}
