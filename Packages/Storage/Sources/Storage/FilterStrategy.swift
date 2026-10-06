import Foundation
import SwiftData

/// Every filter-specific decision for one entity type, bundled as a value.
///
/// Filtering runs in two tiers:
/// 1. `predicate` / `sortDescriptors` / `fetchOffset` / `fetchLimit` push as
///    much of the filter as possible into SQLite.
/// 2. Everything SQLite cannot express is applied in memory through the pure
///    pipeline `matching` → `ordered` → `windowed`.
///
/// The strategy is a plain value rather than a class hierarchy so the pipeline
/// can be unit-tested without a `ModelContainer`, and so `EntityStorage` does
/// not grow a hook it forgot to document. Each hook is a pure function of its
/// input, so a caller's array can never be mutated behind its back.
struct FilterStrategy<Entity, Filter> {
    /// Sort applied when `sortDescriptors(from:)` returns `nil`.
    var defaultSortDescriptors: [SortDescriptor<Entity>]

    /// SQLite-level filtering. Returns `nil` to fall back to the full
    /// in-memory pipeline over `filtered(_:in:)`.
    var predicate: (Filter) -> Predicate<Entity>?

    /// SQLite-level sorting. Returns `nil` to use `defaultSortDescriptors`.
    var sortDescriptors: (Filter) -> [SortDescriptor<Entity>]?

    /// SQLite-level pagination (e.g. an API-style offset/limit window).
    var fetchOffset: (Filter) -> Int?
    var fetchLimit: (Filter) -> Int?

    /// Whether `postProcess` will touch the results of a predicate fetch.
    ///
    /// Checked *before* fetching: SQLite may only apply offset/limit when
    /// nothing will drop or reorder rows afterwards. The factories wire
    /// `postProcess` to guard on this same condition, so the two cannot drift.
    var requiresPostProcessing: (Filter) -> Bool

    /// Post-processing for results of a predicate fetch: filters/sorts SQLite
    /// cannot express. Must be a no-op unless `requiresPostProcessing` says so.
    var postProcess: (Filter, inout [Entity]) -> Void

    /// Keeps only the rows the filter selects. Single source of truth for
    /// matching semantics; `predicate` is a performance mirror of it that the
    /// parity tests keep honest.
    var matching: (Filter, [Entity]) -> [Entity]

    /// Single source of truth for ordering: forward order per filter, with
    /// `reverse` applied by the caller-side wrapper. Must agree with what
    /// `sortDescriptors` hands to SQLite.
    var ordered: (Filter, [Entity]) -> [Entity]

    /// Applies offset/limit in memory.
    var windowed: (Filter, [Entity]) -> [Entity]

    /// Pure in-memory fallback: filter, order, then paginate.
    func filtered(_ filter: Filter, in all: [Entity]) -> [Entity] {
        windowed(filter, ordered(filter, matching(filter, all)))
    }
}
