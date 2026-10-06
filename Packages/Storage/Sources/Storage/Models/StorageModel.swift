import Foundation
import SwiftData

/// What the storage layer requires of every SwiftData model it manages.
///
/// Deliberately internal: only models defined inside this package are stored,
/// so the upsert key and field mapping stay behind the package boundary (see
/// `FacetEntity` for why the DTO layer does not expose this).
///
/// The DTO bridging (`DTO`, `persist`, `apply`) keeps every stored field list
/// in exactly one place per model: `apply` is the single field-by-field
/// mapping, `persist` builds a fresh row through it, and `applyUpdate` reuses
/// it so re-imports overwrite rows in place.
protocol StorageModel: PersistentModel & StorageUpsertKey {
    associatedtype DTO

    /// Builds a detached model from a public DTO. Never inserts it; the
    /// background writer owns insertion.
    static func persist(_ dto: DTO) -> Self

    /// Overwrites every stored field from `dto`.
    func apply(from dto: DTO)

    /// Copies every stored field from another model of the same type.
    /// Used by the writer to update matched rows while keeping row identity.
    func applyUpdate(from other: Self)

    /// Converts this model instance to its DTO representation.
    func toDTO() -> DTO

    /// Fetch predicate selecting rows whose unique key is contained in `keys`.
    /// Built per model because only the model knows its concrete stored key
    /// property — `#Predicate` cannot follow key paths into protocols.
    static func predicate(forKeys keys: [String]) -> Predicate<Self>
}
