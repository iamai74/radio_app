import Foundation

public struct StationFilter: Hashable {
    public var country: String?
    public var language: String?
    public var tag: String?
    public var name: String?
    public var limit: Int?
    public var offset: Int?
    public var orderBy: StationOrderBy = .name
    public var reverse: Bool = false

    public enum StationOrderBy: String, Hashable {
        case name
        case votes
        case bitrate
        case lastCheckOk
        case changeCounter
    }

    public static var empty: StationFilter { StationFilter() }

    public init() {}
}

public struct FacetFilter: Hashable {
    public var name: String?
    public var minStationCount: Int?
    public var orderBy: FacetOrderBy = .name
    public var reverse: Bool = false

    public enum FacetOrderBy: String, Hashable {
        case name
        case stationCount
    }

    public static var empty: FacetFilter { FacetFilter() }
}

public typealias CountryFilter = FacetFilter
public typealias TagFilter = FacetFilter
public typealias LanguageFilter = FacetFilter
public typealias CodecFilter = FacetFilter
