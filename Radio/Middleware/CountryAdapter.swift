import Foundation
import RadioBrowserAPI
import Storage

struct CountryAdapter: CountryEntity {
    let name: String
    let iso31661: String
    let stationCount: Int

    init(from country: some Country) {
        self.name = country.name
        self.iso31661 = country.iso31661
        self.stationCount = country.stationCount
    }
}
