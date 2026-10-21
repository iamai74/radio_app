import Foundation
import Storage
import UILibrary

/// Maps the API's station payload onto the package's default DTO.
///
/// The mapping lives here (app layer) because `StationRecord` must not depend
/// on `RadioBrowserAPI`; everything else — persistence, publication — is the
/// package's job.
extension StationRecord {
    init(from station: some ApiStation) {
        self.init(
            id: station.id,
            name: station.name,
            url: station.url,
            country: station.country,
            homepage: station.homepage,
            favicon: station.favicon,
            tags: station.tags,
            state: station.state,
            language: station.language,
            votes: station.votes,
            codec: station.codec,
            bitrate: station.bitrate,
            lastCheckOk: station.lastCheckOk,
            lastCheckTime: station.lastCheckTime,
            lastCheckTotal: station.lastCheckTotal ?? 0,
            lastCheckFailures: station.lastCheckFailures ?? 0,
            lastCheckDuration: station.lastCheckDuration ?? 0,
            lastCheckError: station.lastCheckError,
            lastChangeTime: station.lastChangeTime,
            changeCounter: station.changeCounter ?? 0,
            creationTime: station.creationTime,
            urlResolved: station.urlResolved
        )
    }
}

/// UI-facing station wrapper that conforms to the UILibrary Station protocol.
/// Bridges storage entities to UI components without leaking mock types.
struct StorageStation: UILibrary.Station {
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
    let bitrate: Int?
    let lastCheckOk: Bool
    let isFavorite: Bool

    init(from entity: any StationEntity) {
        self.id = entity.id
        self.name = entity.name
        self.url = entity.url
        self.homepage = entity.homepage
        self.favicon = entity.favicon
        self.tags = entity.tags
        self.country = entity.country
        self.state = entity.state
        self.language = entity.language
        self.votes = entity.votes
        self.bitrate = entity.bitrate
        self.lastCheckOk = entity.lastCheckOk
        self.isFavorite = false
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: StorageStation, rhs: StorageStation) -> Bool {
        lhs.id == rhs.id
    }
}
