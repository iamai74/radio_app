import Foundation
import SwiftData

struct FetchPlan<Entity> {
    var predicate: Predicate<Entity>?
    var sortDescriptors: [SortDescriptor<Entity>]
    var windowInSQLite: Bool
    var offset: Int?
    var limit: Int?
}

struct FilterStrategy<Entity, Filter> {
    var defaultSortDescriptors: [SortDescriptor<Entity>]
    var plan: (Filter) -> FetchPlan<Entity>
    var postProcess: (Filter, inout [Entity]) -> Void
    var matching: (Filter, [Entity]) -> [Entity]
    var ordered: (Filter, [Entity]) -> [Entity]
    var windowed: (Filter, [Entity]) -> [Entity]

    func filtered(_ filter: Filter, in all: [Entity]) -> [Entity] {
        windowed(filter, ordered(filter, matching(filter, all)))
    }
}
