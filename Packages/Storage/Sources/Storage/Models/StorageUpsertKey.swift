import Foundation

/// Unique key an entity is upserted by: `id` for stations, `name` for facets.
internal protocol StorageUpsertKey {
    var storageKey: String { get }
}
