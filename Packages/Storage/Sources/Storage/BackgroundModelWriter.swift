import Foundation
import SwiftData

/// Owns a private background `ModelContext` and performs every write to it.
///
/// Reads and publication stay on the main actor inside `BaseStorage`; only
/// `upsert` and `deleteAll` cross over to this actor, so bulk imports never
/// block the UI. Writes are serialised through the actor, which also means a
/// single `ModelContext` is never touched from two tasks at once.
actor BackgroundModelWriter {
    private let context: ModelContext

    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }

    /// Delete-then-insert per `key`, so re-importing the same rows updates them
    /// instead of violating the unique constraint.
    ///
    /// `key` is passed in rather than constrained on the writer so that reading
    /// `StorageUpsertKey` never has to cross the actor boundary.
    func upsert<Entity: PersistentModel>(
        _ models: DetachedModels<Entity>,
        key: @escaping @Sendable (Entity) -> String
    ) throws {
        let entities = models.value
        let existing = try context.fetch(FetchDescriptor<Entity>())
        let existingByKey = Dictionary(
            existing.map { (key($0), $0) },
            uniquingKeysWith: { first, _ in first }
        )

        for entity in entities {
            if let existingEntity = existingByKey[key(entity)] {
                context.delete(existingEntity)
            }
            context.insert(entity)
        }

        try context.save()
    }

    func deleteAll<Entity: PersistentModel>(_ type: Entity.Type) throws {
        try context.delete(model: Entity.self)
        try context.save()
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
