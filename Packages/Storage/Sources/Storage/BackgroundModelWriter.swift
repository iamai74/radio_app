import Foundation
import SwiftData

/// Owns a private background `ModelContext` and performs every write to it.
///
/// Reads and publication stay on the main actor inside `EntityStorage`; only
/// `upsert` and `deleteAll` cross over to this actor, so bulk imports never
/// block the UI. Writes are serialised through the actor, which also means a
/// single `ModelContext` is never touched from two tasks at once.
actor BackgroundModelWriter {
    /// Rows fetched per keyed lookup: bounds the `IN (…)` list instead of
    /// loading the whole table on every save.
    private static let fetchChunkSize = 256
    /// Rows written between `save()` calls during a bulk import.
    private static let saveBatchSize = 500

    private let context: ModelContext

    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }

    /// Keyed upsert: matched rows are updated in place, new keys are inserted.
    ///
    /// Updating instead of delete-then-insert keeps row identity, so objects
    /// the main context already handed out stay valid and pick up the new
    /// values on the next fetch. Existing rows are looked up by key in chunks —
    /// a full-table fetch per import was the previous cost of this method.
    func upsert<Entity: StorageModel>(_ models: DetachedModels<Entity>) throws {
        let incoming = Self.deduplicatedByKey(models.value)
        guard !incoming.isEmpty else { return }

        var existingByKey: [String: Entity] = [:]
        let keys = incoming.map(\.storageKey)
        for chunk in keys.chunked(Self.fetchChunkSize) {
            let rows = try context.fetch(FetchDescriptor<Entity>(predicate: Entity.predicate(forKeys: chunk)))
            for row in rows {
                existingByKey[row.storageKey] = row
            }
        }

        var pendingSaves = 0
        for model in incoming {
            if let existing = existingByKey[model.storageKey] {
                existing.applyUpdate(from: model)
            } else {
                context.insert(model)
            }
            pendingSaves += 1
            if pendingSaves >= Self.saveBatchSize {
                try context.save()
                pendingSaves = 0
            }
        }
        if pendingSaves > 0 {
            try context.save()
        }
    }

    func deleteAll<Entity: PersistentModel>(_ type: Entity.Type) throws {
        try context.delete(model: Entity.self)
        try context.save()
    }

    /// Keeps the last model per key, in first-seen order of those last
    /// occurrences, so a batch containing duplicate keys cannot violate the
    /// unique attribute of the model.
    private static func deduplicatedByKey<Entity: StorageModel>(_ models: [Entity]) -> [Entity] {
        var seenKeys = Set<String>()
        var keptReversed: [Entity] = []
        keptReversed.reserveCapacity(models.count)
        for model in models.reversed() where seenKeys.insert(model.storageKey).inserted {
            keptReversed.append(model)
        }
        return keptReversed.reversed()
    }
}

private extension Array {
    /// Splits the array into sub-arrays of at most `size` elements.
    func chunked(_ size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { start in
            Array(self[start ..< Swift.min(start + size, count)])
        }
    }
}

/// Carries freshly built models into `BackgroundModelWriter`.
///
/// `PersistentModel` is not `Sendable`, so the compiler cannot prove the
/// hand-off is safe. It is: the models are constructed on the main actor and
/// never inserted into the main `ModelContext`, and the writer uses each of
/// them exactly once inside its own isolation.
struct DetachedModels<Entity: PersistentModel>: @unchecked Sendable {
    let value: [Entity]

    init(_ value: [Entity]) {
        self.value = value
    }
}
