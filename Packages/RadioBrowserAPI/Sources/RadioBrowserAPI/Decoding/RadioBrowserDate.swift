import Foundation

/// Parses the timestamp formats the Radio Browser API mixes.
///
/// Stations carry both a zone-less `2026-09-30 16:39:46` value and an ISO 8601
/// `2026-09-30T16:39:46Z` one, with or without fractional seconds. The zone-less values are
/// UTC, which is what the service serves, and they are parsed without `DateFormatter` to keep
/// decoding allocation free and safe to call from any thread.
enum RadioBrowserDate {
    /// Parses ISO 8601, falling back to the zone-less format used by the service.
    /// - Parameter value: Timestamp as delivered by the API.
    /// - Returns: The parsed date, or `nil` when the layout is not recognised.
    static func date(from value: String) -> Date? {
        if let date = iso8601Formatter.date(from: value) {
            return date
        }

        if let date = iso8601FormatterWithFractionalSeconds.date(from: value) {
            return date
        }

        return utcDate(from: value)
    }

    /// Both formatters are configured once, inside their initialiser closures, and only
    /// read afterwards; `nonisolated(unsafe)` pins that conclusion instead of paying for
    /// a formatter per parsed timestamp.
    nonisolated(unsafe) private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    nonisolated(unsafe) private static let iso8601FormatterWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let utcTimeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    /// Parses `yyyy-MM-dd` + (`T` or space) + `HH:mm:ss`, treating the value as UTC.
    private static func utcDate(from value: String) -> Date? {
        let parts = value.split(whereSeparator: { $0 == "T" || $0 == " " })
        guard parts.count == 2 else {
            return nil
        }

        let day = parts[0].split(separator: "-").compactMap { Int($0) }
        let time = parts[1].split(separator: ".").first?.split(separator: ":").compactMap { Int($0) }

        guard day.count == 3, let hours = time?.first, let minutes = time?.dropFirst().first else {
            return nil
        }

        var components = DateComponents()
        components.year = day[0]
        components.month = day[1]
        components.day = day[2]
        components.hour = hours
        components.minute = minutes
        components.second = time?.dropFirst(2).first ?? 0

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcTimeZone

        return calendar.date(from: components)
    }
}
