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

    /// Creates the container for the storage schema.
    ///
    /// - Parameter isInMemory: `true` for tests and previews, which need a store
    ///   that is isolated from the on-disk one and from each other.
    public static func create(isInMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
