import Foundation
import RadioBrowserAPI
import Storage

struct TagAdapter: Sendable, TagEntity {
    let name: String
    let stationCount: Int

    init(from tag: some StationTag) {
        self.name = tag.name
        self.stationCount = tag.stationCount
    }
}
