import Foundation

public struct FacetFilter: Hashable, Sendable {
    public var name: String?
    public var minStationCount: Int?
    public var orderBy: FacetOrderBy
    public var reverse: Bool

    public init(
        name: String? = nil,
        minStationCount: Int? = nil,
        orderBy: FacetOrderBy = .name,
        reverse: Bool = false
    ) {
        self.name = name
        self.minStationCount = minStationCount
        self.orderBy = orderBy
        self.reverse = reverse
    }

    public static let empty = FacetFilter()
}

public enum FacetOrderBy: Hashable, Sendable {
    case name
    case stationCount
}
