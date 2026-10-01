import Foundation
import SwiftData

public enum StorageContainer {
    public static func create() throws -> ModelContainer {
        let schema = Schema([
            StationEntityImpl.self,
            CountryEntityImpl.self,
            TagEntityImpl.self,
            LanguageEntityImpl.self,
            CodecEntityImpl.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
