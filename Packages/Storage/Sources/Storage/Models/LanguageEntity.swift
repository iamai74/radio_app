import Foundation
import SwiftData

@Model
final class LanguageEntityImpl: LanguageEntity, FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

extension LanguageEntityImpl: StorageModel {
    typealias DTO = LanguageEntity

    var storageKey: String { name }

    static func persist(_ dto: LanguageEntity) -> LanguageEntityImpl {
        let language = LanguageEntityImpl(name: dto.name, stationCount: 0)
        language.apply(from: dto)
        return language
    }

    func apply(from dto: LanguageEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: LanguageEntityImpl) {
        apply(from: other)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<LanguageEntityImpl> {
        #Predicate { language in
            keys.contains(language.name)
        }
    }
}
