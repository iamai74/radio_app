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

    public enum StationOrderBy: String, CaseIterable, Hashable {
        case name
        case votes
        case bitrate
        case lastCheckOk
        case changeCounter
    }

    public static var empty: StationFilter { StationFilter() }
    
    public init() {}
}

public struct CountryFilter: Hashable {
    public var name: String?
    public var minStationCount: Int?
    public var orderBy: CountryOrderBy = .name
    public var reverse: Bool = false

    public enum CountryOrderBy: String, CaseIterable, Hashable {
        case name
        case stationCount
    }

    public static var empty: CountryFilter { CountryFilter() }
    
    public init() {}
}

public struct TagFilter: Hashable {
    public var name: String?
    public var minStationCount: Int?
    public var orderBy: TagOrderBy = .name
    public var reverse: Bool = false

    public enum TagOrderBy: String, CaseIterable, Hashable {
        case name
        case stationCount
    }

    public static var empty: TagFilter { TagFilter() }
    
    public init() {}
}

public struct LanguageFilter: Hashable {
    public var name: String?
    public var minStationCount: Int?
    public var orderBy: LanguageOrderBy = .name
    public var reverse: Bool = false

    public enum LanguageOrderBy: String, CaseIterable, Hashable {
        case name
        case stationCount
    }

    public static var empty: LanguageFilter { LanguageFilter() }
    
    public init() {}
}

public struct CodecFilter: Hashable {
    public var name: String?
    public var minStationCount: Int?
    public var orderBy: CodecOrderBy = .name
    public var reverse: Bool = false

    public enum CodecOrderBy: String, CaseIterable, Hashable {
        case name
        case stationCount
    }

    public static var empty: CodecFilter { CodecFilter() }
    
    public init() {}
}
