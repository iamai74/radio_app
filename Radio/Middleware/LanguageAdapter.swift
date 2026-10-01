import Foundation
import RadioBrowserAPI
import Storage

struct LanguageAdapter: LanguageEntity {
    let name: String
    let stationCount: Int

    init(from language: some Language) {
        self.name = language.name
        self.stationCount = language.stationCount
    }
}
