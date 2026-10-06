import Foundation
import RadioBrowserAPI
import Storage

extension LanguageRecord {
    init(from language: some Language) {
        self.init(name: language.name, stationCount: language.stationCount)
    }
}
