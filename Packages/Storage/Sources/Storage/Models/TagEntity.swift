import Foundation
import SwiftData

@Model
final class TagEntityImpl: TagEntity, FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
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
        apply(from: other)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<TagEntityImpl> {
        #Predicate { tag in
            keys.contains(tag.name)
        }
    }
}
