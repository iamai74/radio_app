import Foundation

/// Query items shared by the station lookups.
enum QueryItems {
    /// The `limit` item, omitted when the value cannot restrict the result set.
    static func limit(_ limit: Int) -> [URLQueryItem] {
        limit > 0 ? [URLQueryItem(name: "limit", value: String(limit))] : []
    }
}
