import Foundation
import SwiftData

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

extension CountryEntityImpl: StorageModel {
    typealias DTO = CountryEntity

    var storageKey: String { name }

    static func persist(_ dto: CountryEntity) -> CountryEntityImpl {
        let country = CountryEntityImpl(name: dto.name, iso31661: dto.iso31661, stationCount: 0)
        country.apply(from: dto)
        return country
    }

    func apply(from dto: CountryEntity) {
        name = dto.name
        iso31661 = dto.iso31661
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: CountryEntityImpl) {
        apply(from: other)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CountryEntityImpl> {
        #Predicate { country in
            keys.contains(country.name)
        }
    }
}
