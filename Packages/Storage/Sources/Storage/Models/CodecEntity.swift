import Foundation
import SwiftData

@Model
final class CodecEntityImpl: FacetEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

/// Concrete DTO for CodecEntity protocol.
/// Used to bridge between non-Sendable SwiftData models and the public Sendable protocol.
struct CodecDTO: CodecEntity {
    let name: String
    let stationCount: Int
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
        name = other.name
        stationCount = other.stationCount
    }

    func toDTO() -> CodecEntity {
        CodecDTO(name: name, stationCount: stationCount)
    }

    static func predicate(forKeys keys: [String]) -> Predicate<CodecEntityImpl> {
        #Predicate { codec in
            keys.contains(codec.name)
        }
    }
}
