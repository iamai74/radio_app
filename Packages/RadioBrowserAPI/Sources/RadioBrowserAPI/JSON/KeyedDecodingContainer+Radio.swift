import Foundation

/// Decoding helpers for the Radio Browser payloads.
///
/// The service is not type consistent: booleans are sent as `1`/`0`, tag lists as a comma
/// separated string, optional values as an empty string instead of being omitted, and
/// station names come padded with tabs and newlines.
extension KeyedDecodingContainer {
    /// Decodes a boolean sent as `true`/`false`, `1`/`0` or `"true"`/`"false"`.
    ///
    /// Missing and null values decode as `false`, which is how the service reports an
    /// unchecked station.
    func decodeFlexibleBool(forKey key: Key) throws -> Bool {
        if let value = try? decodeIfPresent(Bool.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return value != 0
        }
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            return ["true", "1", "yes"].contains(value.lowercased())
        }

        return false
    }

    /// Decodes a list sent either as a JSON array or as a comma separated string.
    ///
    /// `""` and `null` both decode as `nil` instead of an empty list.
    func decodeStringList(forKey key: Key) throws -> [String]? {
        if let list = try? decodeIfPresent([String].self, forKey: key) {
            return list.nonEmptyTrimmed
        }

        guard let raw = try? decodeIfPresent(String.self, forKey: key) else {
            return nil
        }

        return raw.split(separator: ",").map(String.init).nonEmptyTrimmed
    }

    /// Decodes a string, treating `null` and `""` as `nil`.
    func decodeOptionalString(forKey key: Key) throws -> String? {
        guard let value = try? decodeIfPresent(String.self, forKey: key) else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmed.isEmpty ? nil : trimmed
    }

    /// Decodes a mandatory string, trimming the padding the service adds to station names.
    func decodeString(forKey key: Key) throws -> String {
        let value = try decode(String.self, forKey: key)

        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Decodes an integer, tolerating `null`, absent keys and numeric strings.
    func decodeOptionalInt(forKey key: Key) throws -> Int? {
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return value
        }
        if let raw = try? decodeIfPresent(String.self, forKey: key) {
            return Int(raw.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return nil
    }

    /// Decodes an integer that the service may omit entirely.
    func decodeInt(forKey key: Key, default defaultValue: Int = 0) throws -> Int {
        try decodeOptionalInt(forKey: key) ?? defaultValue
    }
}

private extension Array where Element == String {
    /// Trimmed copy without blank entries, or `nil` when nothing is left.
    var nonEmptyTrimmed: [String]? {
        let values = map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }

        return values.isEmpty ? nil : values
    }
}
