import Foundation
import SwiftData

@Model
final class TagEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }

    typealias DTO = TagEntity
    var storageKey: String { name }

    static func persist(_ dto: TagEntity) -> TagEntityImpl {
        TagEntityImpl(name: dto.name, stationCount: dto.stationCount)
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
        TagDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<TagEntityImpl> {
        #Predicate { tag in keys.contains(tag.name) }
    }
}

struct TagDTO: TagEntity, Equatable {
    let name: String
    let stationCount: Int

    static func from(_ impl: TagEntityImpl) -> TagDTO {
        TagDTO(name: impl.name, stationCount: impl.stationCount)
    }
}
