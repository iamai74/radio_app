import Foundation
import SwiftData

@Model
final class CountryEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var iso31661: String
    var stationCount: Int

    init(name: String, iso31661: String, stationCount: Int = 0) {
        self.name = name
        self.iso31661 = iso31661
        self.stationCount = stationCount
    }

    typealias DTO = CountryEntity
    var storageKey: String { name }

    static func persist(_ dto: CountryEntity) -> CountryEntityImpl {
        CountryEntityImpl(name: dto.name, iso31661: dto.iso31661, stationCount: dto.stationCount)
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
        CountryDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CountryEntityImpl> {
        #Predicate { country in keys.contains(country.name) }
    }
}

struct CountryDTO: CountryEntity, Equatable {
    let name: String
    let iso31661: String
    let stationCount: Int

    static func from(_ impl: CountryEntityImpl) -> CountryDTO {
        CountryDTO(name: impl.name, iso31661: impl.iso31661, stationCount: impl.stationCount)
    }
}
