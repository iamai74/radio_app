import Foundation
import SwiftData

extension CountryEntityImpl: StorageUpsertKey {
    var storageKey: String { name }
}

@Model
final class CountryEntityImpl: CountryEntity, FacetEntity {
    @Attribute(.unique) var name: String
    var iso31661: String
    var stationCount: Int

    init(name: String, iso31661: String, stationCount: Int) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }
}

extension CountryEntityImpl {
    static func from(_ country: some CountryEntity) -> CountryEntityImpl {
        CountryEntityImpl(
            name: country.name,
            iso31661: country.iso31661,
            stationCount: country.stationCount
        )
    }
}
