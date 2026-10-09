import Foundation
import RadioBrowserAPI
import Storage

extension TagRecord {
    init(from tag: some StationTag) {
        self.init(name: tag.name, stationCount: tag.stationCount)
    }
}
