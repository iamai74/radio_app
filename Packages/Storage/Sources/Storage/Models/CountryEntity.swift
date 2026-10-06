import Foundation
import SwiftData

@Model
final class CountryEntityImpl: FacetEntity {
    @Attribute(.unique) var name: String
    var iso31661: String
    var stationCount: Int

    init(name: String, iso31661: String, stationCount: Int) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }
}

/// Concrete DTO for CountryEntity protocol.
/// Used to bridge between non-Sendable SwiftData models and the public Sendable protocol.
struct CountryDTO: CountryEntity {
    let name: String
    let iso31661: String
    let stationCount: Int
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
        name = other.name
        iso31661 = other.iso31661
        stationCount = other.stationCount
    }

    func toDTO() -> CountryEntity {
        CountryDTO(name: name, iso31661: iso31661, stationCount: stationCount)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CountryEntityImpl> {
        #Predicate { country in
            keys.contains(country.name)
        }
    }
}
