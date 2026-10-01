import Foundation

public protocol Station {
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

internal struct StationObject: Codable, Station {
    public let id: String
    public let name: String
    public let url: String
    public let homepage: String?
    public let favicon: String?
    public let tags: [String]?
    public let country: String
    public let state: String?
    public let language: String?
    public let votes: Int
    public let codec: String?
    public let bitrate: Int?
    public let lastCheckOk: Bool
    public let lastCheckTime: Date?
    public let lastCheckTotal: Int
    public let lastCheckFailures: Int
    public let lastCheckDuration: Int
    public let lastCheckError: String?
    public let lastChangeTime: Date?
    public let changeCounter: Int
    public let creationTime: Date?
    public let urlResolved: String?
    
    init(
        id: String,
        name: String,
        url: String,
        homepage: String? = nil,
        favicon: String? = nil,
        tags: [String]? = nil,
        country: String,
        state: String? = nil,
        language: String? = nil,
        votes: Int = 0,
        codec: String? = nil,
        bitrate: Int? = nil,
        lastCheckOk: Bool,
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
        self.homepage = homepage
        self.favicon = favicon
        self.tags = tags
        self.country = country
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