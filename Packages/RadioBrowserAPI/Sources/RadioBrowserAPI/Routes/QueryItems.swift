import Foundation

/// Query items shared by the station lookups and the station query.
enum QueryItems {
    /// The `limit` item, omitted when the value cannot restrict the result set.
    static func limit(_ limit: Int) -> [URLQueryItem] {
        limit > 0 ? [URLQueryItem(name: "limit", value: String(limit))] : []
    }

    /// The `limit` item, sent even when the value cannot restrict the result set.
    ///
    /// ``StationQuery`` promises its paging values reach the service on every request,
    /// so its limit is sent unconditionally — unlike the lookup limits above.
    static func pagingLimit(_ limit: Int) -> [URLQueryItem] {
        [URLQueryItem(name: "limit", value: String(limit))]
    }
}

extension URLQueryItem {
    /// A query item carrying a boolean the way the service reads it: `true` or `false`.
    /// - Parameters:
    ///   - value: The boolean to send.
    ///   - name: The query item name, e.g. `hide_breaks`.
    static func bool(_ value: Bool, name: String) -> URLQueryItem {
        URLQueryItem(name: name, value: value ? "true" : "false")
    }
}
