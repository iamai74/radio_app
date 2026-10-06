import Foundation
import SwiftData

@Model
final class LanguageEntityImpl: FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

/// Concrete DTO for LanguageEntity protocol.
/// Used to bridge between non-Sendable SwiftData models and the public Sendable protocol.
struct LanguageDTO: LanguageEntity {
    let name: String
    let stationCount: Int
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
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> LanguageEntity {
        LanguageDTO(name: name, stationCount: stationCount)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<LanguageEntityImpl> {
        #Predicate { language in
            keys.contains(language.name)
        }
    }
}
