import Foundation
import SwiftData

@Model
final class CodecEntityImpl: CodecEntity, FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

extension CodecEntityImpl: StorageModel {
    typealias DTO = CodecEntity

    var storageKey: String { name }

    static func persist(_ dto: CodecEntity) -> CodecEntityImpl {
        let codec = CodecEntityImpl(name: dto.name, stationCount: 0)
        codec.apply(from: dto)
        return codec
    }

    func apply(from dto: CodecEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: CodecEntityImpl) {
        apply(from: other)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CodecEntityImpl> {
        #Predicate { codec in
            keys.contains(codec.name)
        }
    }
}
