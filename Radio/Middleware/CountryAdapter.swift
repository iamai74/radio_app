import Foundation
import RadioBrowserAPI
import Storage

extension CountryRecord {
    init(from country: some Country) {
        self.init(
            name: country.name,
            iso31661: country.iso31661,
            stationCount: country.stationCount
        )
    }
}
