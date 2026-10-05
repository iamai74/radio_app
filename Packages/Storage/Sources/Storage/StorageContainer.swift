import Foundation
import SwiftData

public enum StorageContainer {
    public static func create(isInMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            StationEntityImpl.self,
            CountryEntityImpl.self,
            TagEntityImpl.self,
            LanguageEntityImpl.self,
            CodecEntityImpl.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemory)
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
