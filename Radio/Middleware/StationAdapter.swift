import Foundation
import RadioBrowserAPI
import Storage

struct StationAdapter: StationEntity {
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

    init(from station: some Station) {
        self.id = station.id
        self.name = station.name
        self.url = station.url
        self.homepage = station.homepage
        self.favicon = station.favicon
        self.tags = station.tags
        self.country = station.country
        self.state = station.state
        self.language = station.language
        self.votes = station.votes
        self.codec = station.codec
        self.bitrate = station.bitrate
        self.lastCheckOk = station.lastCheckOk
        self.lastCheckTime = station.lastCheckTime
        self.lastCheckTotal = station.lastCheckTotal ?? 0
        self.lastCheckFailures = station.lastCheckFailures ?? 0
        self.lastCheckDuration = station.lastCheckDuration ?? 0
        self.lastCheckError = station.lastCheckError
        self.lastChangeTime = station.lastChangeTime
        self.changeCounter = station.changeCounter ?? 0
        self.creationTime = station.creationTime
        self.urlResolved = station.urlResolved
    }
}
