import Foundation
import SwiftData

extension LanguageEntityImpl: StorageUpsertKey {
    var storageKey: String { name }
}

public protocol LanguageEntity {
    var name: String { get }
    var stationCount: Int { get }
}

@Model
final class LanguageEntityImpl: LanguageEntity {
    @Attribute(.unique) var name: String
    var stationCount: Int

    init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }
}

extension LanguageEntityImpl {
    static func from(_ language: some LanguageEntity) -> LanguageEntityImpl {
        LanguageEntityImpl(
            name: language.name,
            stationCount: language.stationCount
        )
    }
}
