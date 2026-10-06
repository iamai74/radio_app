import Foundation
import RadioBrowserAPI
import Storage

/// Maps the API's station payload onto the package's default DTO.
///
/// The mapping lives here (app layer) because `StationRecord` must not depend
/// on `RadioBrowserAPI`; everything else — persistence, publication — is the
/// package's job.
extension StationRecord {
    init(from station: some Station) {
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
