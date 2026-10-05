import Foundation
import SwiftData

extension CodecEntityImpl: StorageUpsertKey {
    var storageKey: String { name }
}

@Model
final class CodecEntityImpl: CodecEntity, FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

extension CodecEntityImpl {
    static func from(_ codec: some CodecEntity) -> CodecEntityImpl {
        CodecEntityImpl(
            name: codec.name,
            stationCount: codec.stationCount
        )
    }
}
