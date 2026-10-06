import Foundation
import SwiftData

/// One filter's resolved SQLite fetch request.
///
/// Computed in a single place per entity type so the pushdown/post-process
/// decision cannot drift from the fetch it configures: the factory that builds
/// a plan decides *both* whether SQLite may apply the offset/limit window and
/// which predicate/sort descriptors travel with it.
struct FetchPlan<Entity> {
    /// SQLite-level filtering. `nil` routes the whole request through the
    /// in-memory pipeline (`FilterStrategy.filtered(_:in:)`).
    var predicate: Predicate<Entity>?

    /// SQLite-level ordering; always concrete so the fetch never relies on an
    /// implicit default.
    var sortDescriptors: [SortDescriptor<Entity>]

    /// True when SQLite may apply `offset`/`limit` to the predicate fetch,
    /// i.e. nothing will drop or reorder rows afterwards. By construction the
    /// factory only fills `offset`/`limit` when this is true.
    var windowInSQLite: Bool

    var offset: Int?
    var limit: Int?
}

/// Every filter-specific decision for one entity type, bundled as a value.
///
/// Filtering runs in two tiers:
/// 1. `plan(for:)` resolves as much of the filter as possible into SQLite
///    (predicate, sort descriptors, window placement).
/// 2. Everything SQLite cannot express is applied in memory through the pure
///    pipeline `matching` → `ordered` → `windowed`; `postProcess` covers the
///    slice of that pipeline a predicate fetch still needs.
///
/// The strategy is a plain value rather than a class hierarchy so the pipeline
/// can be unit-tested without a `ModelContainer`, and so `EntityStorage` does
/// not grow a hook it forgot to document. Each hook is a pure function of its
/// input, so a caller's array can never be mutated behind its back.
struct FilterStrategy<Entity, Filter> {
    /// Sort applied to the unfiltered reload fetch.
    var defaultSortDescriptors: [SortDescriptor<Entity>]

    /// Resolves the SQLite half of a filter: predicate, ordering, and where
    /// the offset/limit window applies. The single owner of "which parts of
    /// this filter can SQLite express".
    var plan: (Filter) -> FetchPlan<Entity>

    /// Post-processing for the results of a predicate fetch: filters/sorts
    /// SQLite cannot express. Only invoked by `EntityStorage` when the plan
    /// says `windowInSQLite == false`.
    var postProcess: (Filter, inout [Entity]) -> Void

    /// Keeps only the rows the filter selects. Single source of truth for
    /// matching semantics; the plan's `predicate` is a performance mirror of
    /// it that the parity tests keep honest.
    var matching: (Filter, [Entity]) -> [Entity]

    /// Single source of truth for ordering: forward order per filter, with
    /// `reverse` applied by the caller-side wrapper. Must agree with the
    /// plan's `sortDescriptors`.
    var ordered: (Filter, [Entity]) -> [Entity]

    /// Applies offset/limit in memory.
    var windowed: (Filter, [Entity]) -> [Entity]

    /// Pure in-memory fallback: filter, order, then paginate.
    func filtered(_ filter: Filter, in all: [Entity]) -> [Entity] {
        windowed(filter, ordered(filter, matching(filter, all)))
    }
}
