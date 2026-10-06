import Foundation
import SwiftData
import StorageCore

@Model
final class StationEntityImpl: StationEntityBase {
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

extension StationEntityImpl: StorageModel {
    typealias DTO = StationEntity

    var storageKey: String { id }

    static func persist(_ dto: StationEntity) -> StationEntityImpl {
        let station = StationEntityImpl(id: dto.id, name: dto.name, url: dto.url, country: dto.country)
        station.apply(from: dto)
        return station
    }

    func apply(from dto: StationEntity) {
        id = dto.id
        name = dto.name
        url = dto.url
        homepage = dto.homepage
        favicon = dto.favicon
        tags = dto.tags
        country = dto.country
        state = dto.state
        language = dto.language
        votes = dto.votes
        codec = dto.codec
        bitrate = dto.bitrate
        lastCheckOk = dto.lastCheckOk
        lastCheckTime = dto.lastCheckTime
        lastCheckTotal = dto.lastCheckTotal
        lastCheckFailures = dto.lastCheckFailures
        lastCheckDuration = dto.lastCheckDuration
        lastCheckError = dto.lastCheckError
        lastChangeTime = dto.lastChangeTime
        changeCounter = dto.changeCounter
        creationTime = dto.creationTime
        urlResolved = dto.urlResolved
    }

    func applyUpdate(from other: StationEntityImpl) {
        id = other.id
        name = other.name
        url = other.url
        homepage = other.homepage
        favicon = other.favicon
        tags = other.tags
        country = other.country
        state = other.state
        language = other.language
        votes = other.votes
        codec = other.codec
        bitrate = other.bitrate
        lastCheckOk = other.lastCheckOk
        lastCheckTime = other.lastCheckTime
        lastCheckTotal = other.lastCheckTotal
        lastCheckFailures = other.lastCheckFailures
        lastCheckDuration = other.lastCheckDuration
        lastCheckError = other.lastCheckError
        lastChangeTime = other.lastChangeTime
        changeCounter = other.changeCounter
        creationTime = other.creationTime
        urlResolved = other.urlResolved
    }

    func toDTO() -> StationEntity {
        StationDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<StationEntityImpl> {
        #Predicate { station in
            keys.contains(station.id)
        }
    }
}

/// Lightweight DTO that conforms to `StationEntity` for publishing results.
/// `StationEntityImpl` cannot conform to `StationEntity` directly because
/// SwiftData `@Model` classes cannot be `Sendable`.
struct StationDTO: StationEntity, Equatable {
    let id: String
    let name: String
    let url: String
    let homepage: String?
    let favicon: String?
    let tags: [String]?
    let country: String
    let state: String?
    let language: String?
    let votes: Int
    let codec: String?
    let bitrate: Int?
    let lastCheckOk: Bool
    let lastCheckTime: Date?
    let lastCheckTotal: Int
    let lastCheckFailures: Int
    let lastCheckDuration: Int
    let lastCheckError: String?
    let lastChangeTime: Date?
    let changeCounter: Int
    let creationTime: Date?
    let urlResolved: String?

    static func from(_ impl: StationEntityImpl) -> StationDTO {
        StationDTO(
            id: impl.id,
            name: impl.name,
            url: impl.url,
            homepage: impl.homepage,
            favicon: impl.favicon,
            tags: impl.tags,
            country: impl.country,
            state: impl.state,
            language: impl.language,
            votes: impl.votes,
            codec: impl.codec,
            bitrate: impl.bitrate,
            lastCheckOk: impl.lastCheckOk,
            lastCheckTime: impl.lastCheckTime,
            lastCheckTotal: impl.lastCheckTotal,
            lastCheckFailures: impl.lastCheckFailures,
            lastCheckDuration: impl.lastCheckDuration,
            lastCheckError: impl.lastCheckError,
            lastChangeTime: impl.lastChangeTime,
            changeCounter: impl.changeCounter,
            creationTime: impl.creationTime,
            urlResolved: impl.urlResolved
        )
    }
}
