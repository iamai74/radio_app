import Foundation
import SwiftData

@Model
final class CodecEntityImpl: FacetEntity, StorageModel {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int = 0) {
        self.name = name
        self.stationCount = stationCount
    }

    typealias DTO = CodecEntity
    var storageKey: String { name }

    static func persist(_ dto: CodecEntity) -> CodecEntityImpl {
        CodecEntityImpl(name: dto.name, stationCount: dto.stationCount)
    }

    func apply(from dto: CodecEntity) {
        name = dto.name
        stationCount = dto.stationCount
    }

    func applyUpdate(from other: CodecEntityImpl) {
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> CodecEntity {
        CodecDTO.from(self)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CodecEntityImpl> {
        #Predicate { codec in keys.contains(codec.name) }
    }
}

struct CodecDTO: CodecEntity, Equatable {
    let name: String
    let stationCount: Int

    static func from(_ impl: CodecEntityImpl) -> CodecDTO {
        CodecDTO(name: impl.name, stationCount: impl.stationCount)
    }
}
