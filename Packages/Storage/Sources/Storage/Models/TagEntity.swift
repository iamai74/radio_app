import Foundation
import SwiftData

@Model
final class TagEntityImpl: FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

/// Concrete DTO for TagEntity protocol.
/// Used to bridge between non-Sendable SwiftData models and the public Sendable protocol.
struct TagDTO: TagEntity {
    let name: String
    let stationCount: Int
}

extension TagEntityImpl: StorageModel {
    typealias DTO = TagEntity

    var storageKey: String { name }

    static func persist(_ dto: TagEntity) -> TagEntityImpl {
        let tag = TagEntityImpl(name: dto.name, stationCount: 0)
        tag.apply(from: dto)
        return tag
    }

    func apply(from dto: TagEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: TagEntityImpl) {
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> TagEntity {
        TagDTO(name: name, stationCount: stationCount)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<TagEntityImpl> {
        #Predicate { tag in
            keys.contains(tag.name)
        }
    }
}
