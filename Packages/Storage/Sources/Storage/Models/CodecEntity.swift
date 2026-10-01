import Foundation
import SwiftData

public protocol CodecEntity {
    var name: String { get }
    var stationCount: Int { get }
}

@Model
final class CodecEntityImpl: CodecEntity {
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
