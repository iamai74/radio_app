import Foundation
import SwiftData

@Model
final class LanguageEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }

    typealias DTO = LanguageEntity
    var storageKey: String { name }

    static func persist(_ dto: any LanguageEntity) -> LanguageEntityImpl {
        LanguageEntityImpl(name: dto.name, stationCount: dto.stationCount)
    }

    func apply(from dto: any LanguageEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: LanguageEntityImpl) {
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> any LanguageEntity {
        LanguageDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<LanguageEntityImpl> {
        #Predicate { language in keys.contains(language.name) }
    }
}

struct LanguageDTO: LanguageEntity, Equatable {
    let name: String
    let stationCount: Int

    static func from(_ impl: LanguageEntityImpl) -> LanguageDTO {
        LanguageDTO(name: impl.name, stationCount: impl.stationCount)
    }
}
