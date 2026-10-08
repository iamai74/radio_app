import Foundation

public struct StationFilter: Hashable, Sendable {
    public var name: String?
    public var country: String?
    public var language: String?
    public var tag: String?
    public var orderBy: StationOrderBy
    public var reverse: Bool
    public var limit: Int?
    public var offset: Int?

    public init(
        name: String? = nil,
        country: String? = nil,
        language: String? = nil,
        tag: String? = nil,
        orderBy: StationOrderBy = .name,
        reverse: Bool = false,
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        self.name = name
        self.country = country
        self.language = language
        self.tag = tag
        self.orderBy = orderBy
        self.reverse = reverse
        self.limit = limit
        self.offset = offset
    }

    public static let empty = StationFilter()
}

public enum StationOrderBy: Hashable, Sendable {
    case name
    case votes
    case bitrate
    case changeCounter
    case lastCheckOk
}
