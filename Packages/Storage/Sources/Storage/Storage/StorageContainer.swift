import Foundation
import SwiftData

public enum StorageContainer {
    private static let schema = Schema([
        StationEntityImpl.self,
        CountryEntityImpl.self,
        TagEntityImpl.self,
        LanguageEntityImpl.self,
        CodecEntityImpl.self
    ])

    public static func create(isInMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
