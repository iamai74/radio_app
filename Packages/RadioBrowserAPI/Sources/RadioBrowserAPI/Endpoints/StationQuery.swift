import Foundation

/// The criteria of a station list request.
///
/// A value type replaces what used to be a nine parameter method: defaults live in one
/// place, callers can pass only what they care about, and new criteria are added by
/// adding a property instead of by reshuffling parameters across protocol, implementation
/// and mocks.
public struct StationQuery: Sendable, Equatable {
    /// Filter by country code, or `nil` for every country.
    public var country: String?
    /// Filter by language code, or `nil` for every language.
    public var language: String?
    /// Filter by tag, or `nil` for every tag.
    public var tag: String?
    /// Filter by station name, or `nil` for every name.
    public var name: String?
    /// The maximum number of stations to return.
    public var limit: Int
    /// The number of stations to skip.
    public var offset: Int
    /// Whether to exclude broken stations.
    public var hideBreaks: Bool
    /// The field to order the results by.
    public var order: StationSortOrder
    /// Whether the results are in reverse order.
    public var reverse: Bool

    /// - Parameters:
    ///   - country: Filter by country code, or `nil` for every country.
    ///   - language: Filter by language code, or `nil` for every language.
    ///   - tag: Filter by tag, or `nil` for every tag.
    ///   - name: Filter by station name, or `nil` for every name.
    ///   - limit: The maximum number of stations to return.
    ///   - offset: The number of stations to skip.
    ///   - hideBreaks: Whether to exclude broken stations.
    ///   - order: The field to order the results by.
    ///   - reverse: Whether the results are in reverse order.
    public init(
        country: String? = nil,
        language: String? = nil,
        tag: String? = nil,
        name: String? = nil,
        limit: Int = 100,
        offset: Int = 0,
        hideBreaks: Bool = false,
        order: StationSortOrder = .name,
        reverse: Bool = false
    ) {
        self.country = country
        self.language = language
        self.tag = tag
        self.name = name
        self.limit = limit
        self.offset = offset
        self.hideBreaks = hideBreaks
        self.order = order
        self.reverse = reverse
    }

    /// The criteria with every default: the first hundred stations ordered by name.
    public static let `default` = StationQuery()

    /// The query items as the service expects them: blank criteria are dropped, the paging
    /// and ordering parameters are always sent so a caller gets what it asked for.
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        items.append(contentsOf: Self.criterion(country, name: "country"))
        items.append(contentsOf: Self.criterion(language, name: "language"))
        items.append(contentsOf: Self.criterion(tag, name: "tag"))
        items.append(contentsOf: Self.criterion(name, name: "name"))

        items.append(URLQueryItem(name: "limit", value: String(limit)))
        items.append(URLQueryItem(name: "offset", value: String(offset)))
        items.append(URLQueryItem(name: "hide_breaks", value: hideBreaks ? "true" : "false"))
        items.append(URLQueryItem(name: "order", value: order.rawValue))
        items.append(URLQueryItem(name: "reverse", value: reverse ? "true" : "false"))

        return items
    }

    private static func criterion(_ value: String?, name: String) -> [URLQueryItem] {
        guard let value, !value.isEmpty else {
            return []
        }

        return [URLQueryItem(name: name, value: value)]
    }
}
