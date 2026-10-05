import Foundation
import SwiftData

extension StationEntityImpl: StorageUpsertKey {
    var storageKey: String { id }
}

public protocol StationEntity {
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

@Model
final class StationEntityImpl: StationEntity {
    @Attribute(.unique) var id: String
    var name: String
    var url: String
    var homepage: String?
    var favicon: String?
    var tags: [String]?
    var country: String
    var state: String?
    var language: String?
    var votes: Int
    var codec: String?
    var bitrate: Int?
    var lastCheckOk: Bool
    var lastCheckTime: Date?
    var lastCheckTotal: Int
    var lastCheckFailures: Int
    var lastCheckDuration: Int
    var lastCheckError: String?
    var lastChangeTime: Date?
    var changeCounter: Int
    var creationTime: Date?
    var urlResolved: String?

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

extension StationEntityImpl {
    static func from(_ station: some StationEntity) -> StationEntityImpl {
        StationEntityImpl(
            id: station.id,
            name: station.name,
            url: station.url,
            homepage: station.homepage,
            favicon: station.favicon,
            tags: station.tags,
            country: station.country,
            state: station.state,
            language: station.language,
            votes: station.votes,
            codec: station.codec,
            bitrate: station.bitrate,
            lastCheckOk: station.lastCheckOk,
            lastCheckTime: station.lastCheckTime,
            lastCheckTotal: station.lastCheckTotal,
            lastCheckFailures: station.lastCheckFailures,
            lastCheckDuration: station.lastCheckDuration,
            lastCheckError: station.lastCheckError,
            lastChangeTime: station.lastChangeTime,
            changeCounter: station.changeCounter,
            creationTime: station.creationTime,
            urlResolved: station.urlResolved
        )
    }
}
