import Foundation
import SwiftData

extension TagEntityImpl: StorageUpsertKey {
    var storageKey: String { name }
}

@Model
final class TagEntityImpl: TagEntity, FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

extension TagEntityImpl {
    static func from(_ tag: some TagEntity) -> TagEntityImpl {
        TagEntityImpl(
            name: tag.name,
            stationCount: tag.stationCount
        )
    }
}
