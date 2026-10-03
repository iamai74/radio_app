import Foundation

/// A protocol representing a radio station.
public protocol Station: Decodable, Sendable {
    /// The unique identifier of the station.
    var id: String { get }

    /// The name of the station.
    var name: String { get }

    /// The streaming URL of the station.
    var url: String { get }

    /// The homepage URL of the station.
    var homepage: String? { get }

    /// The favicon URL of the station.
    var favicon: String? { get }

    /// Tags associated with the station, split from the comma separated list of the API.
    ///
    /// Only commas are treated as separators: the service also reports some tag lists
    /// separated by spaces, while real tags such as `classic rock` contain spaces themselves.
    /// `nil` when the station carries no tags.
    var tags: [String]? { get }

    /// The country where the station is located, as the full name the API reports.
    var country: String { get }

    /// The state/region where the station is located.
    var state: String? { get }

    /// The language spoken on the station.
    var language: String? { get }

    /// The number of votes the station has received.
    var votes: Int { get }

    /// The audio codec used by the station.
    var codec: String? { get }

    /// The bitrate of the station's audio stream.
    var bitrate: Int? { get }

    /// Whether the last check of the station was successful.
    var lastCheckOk: Bool { get }

    /// The time when the last check was performed.
    var lastCheckTime: Date? { get }

    /// The total number of checks performed on this station.
    ///
    /// Not reported by every endpoint, hence optional.
    var lastCheckTotal: Int? { get }

    /// The number of failures during the last check.
    ///
    /// Not reported by every endpoint, hence optional.
    var lastCheckFailures: Int? { get }

    /// The duration of the last check in milliseconds.
    ///
    /// Not reported by every endpoint, hence optional.
    var lastCheckDuration: Int? { get }

    /// Error message from the last check, if any.
    var lastCheckError: String? { get }

    /// The time when the station was last modified.
    var lastChangeTime: Date? { get }

    /// A counter for how many changes have been made to this station.
    ///
    /// Not reported by every endpoint, hence optional.
    var changeCounter: Int? { get }

    /// The creation time of this station.
    var creationTime: Date? { get }

    /// The resolved URL after checking the station's stream.
    var urlResolved: String? { get }
}

/// An internal struct implementing the Station protocol with Codable conformance.
package struct StationObject: Codable, Station {
    public let id: String
    public let name: String
    public let url: String
    public let homepage: String?
    public let favicon: String?
    public let tags: [String]?
    public let country: String
    public let state: String?
    public let language: String?
    public let votes: Int
    public let codec: String?
    public let bitrate: Int?
    public let lastCheckOk: Bool
    public let lastCheckTime: Date?
    public let lastCheckTotal: Int?
    public let lastCheckFailures: Int?
    public let lastCheckDuration: Int?
    public let lastCheckError: String?
    public let lastChangeTime: Date?
    public let changeCounter: Int?
    public let creationTime: Date?
    public let urlResolved: String?

    /// Initializes the StationObject with all its properties.
    /// - Parameters:
    ///   - id: The unique identifier of the station.
    ///   - name: The name of the station.
    ///   - url: The streaming URL of the station.
    ///   - homepage: The homepage URL of the station.
    ///   - favicon: The favicon URL of the station.
    ///   - tags: Tags associated with the station.
    ///   - country: The country where the station is located.
    ///   - state: The state/region where the station is located.
    ///   - language: The language spoken on the station.
    ///   - votes: The number of votes the station has received.
    ///   - codec: The audio codec used by the station.
    ///   - bitrate: The bitrate of the station's audio stream.
    ///   - lastCheckOk: Whether the last check of the station was successful.
    ///   - lastCheckTime: The time when the last check was performed.
    ///   - lastCheckTotal: The total number of checks performed on this station.
    ///   - lastCheckFailures: The number of failures during the last check.
    ///   - lastCheckDuration: The duration of the last check in milliseconds.
    ///   - lastCheckError: Error message from the last check, if any.
    ///   - lastChangeTime: The time when the station was last modified.
    ///   - changeCounter: A counter for how many changes have been made to this station.
    ///   - creationTime: The creation time of this station.
    ///   - urlResolved: The resolved URL after checking the station's stream.
    package init(
        id: String,
        name: String,
        url: String,
        homepage: String? = nil,
        favicon: String? = nil,
        tags: [String]? = nil,
        country: String,
        state: String? = nil,
        language: String? = nil,
        votes: Int = 0,
        codec: String? = nil,
        bitrate: Int? = nil,
        lastCheckOk: Bool = false,
        lastCheckTime: Date? = nil,
        lastCheckTotal: Int? = nil,
        lastCheckFailures: Int? = nil,
        lastCheckDuration: Int? = nil,
        lastCheckError: String? = nil,
        lastChangeTime: Date? = nil,
        changeCounter: Int? = nil,
        creationTime: Date? = nil,
        urlResolved: String? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.homepage = homepage
        self.favicon = favicon
        self.tags = tags
        self.country = country
        self.state = state
        self.language = language
        self.votes = votes
        self.codec = codec
        self.bitrate = bitrate
        self.lastCheckOk = lastCheckOk
        self.lastCheckTime = lastCheckTime
        self.lastCheckTotal = lastCheckTotal
        self.lastCheckFailures = lastCheckFailures
        self.lastCheckDuration = lastCheckDuration
        self.lastCheckError = lastCheckError
        self.lastChangeTime = lastChangeTime
        self.changeCounter = changeCounter
        self.creationTime = creationTime
        self.urlResolved = urlResolved
    }

    /// Decodes a station, tolerating the layout differences of the service:
    /// `lastcheckok` arrives as `1`/`0`, `tags` as a comma separated string, timestamps in
    /// two layouts and the check counters are missing from the list endpoints.
    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeString(forKey: .id)
        name = try container.decodeString(forKey: .name)
        url = try container.decodeString(forKey: .url)
        country = try container.decodeString(forKey: .country)
        votes = try container.decodeInt(forKey: .votes)
        lastCheckOk = try container.decodeFlexibleBool(forKey: .lastCheckOk)
        homepage = try container.decodeOptionalString(forKey: .homepage)
        favicon = try container.decodeOptionalString(forKey: .favicon)
        tags = try container.decodeStringList(forKey: .tags)
        state = try container.decodeOptionalString(forKey: .state)
        language = try container.decodeOptionalString(forKey: .language)
        codec = try container.decodeOptionalString(forKey: .codec)
        bitrate = try container.decodeOptionalInt(forKey: .bitrate)
        lastCheckTime = try Self.decodeDate(forKey: .lastCheckTime, using: decoder)
        lastCheckTotal = try container.decodeOptionalInt(forKey: .lastCheckTotal)
        lastCheckFailures = try container.decodeOptionalInt(forKey: .lastCheckFailures)
        lastCheckDuration = try container.decodeOptionalInt(forKey: .lastCheckDuration)
        lastCheckError = try container.decodeOptionalString(forKey: .lastCheckError)
        lastChangeTime = try Self.decodeDate(forKey: .lastChangeTime, using: decoder)
        changeCounter = try container.decodeOptionalInt(forKey: .changeCounter)
        creationTime = try Self.decodeDate(forKey: .creationTime, using: decoder)
        urlResolved = try container.decodeOptionalString(forKey: .urlResolved)
    }

    /// Prefers the ISO 8601 flavour of a timestamp, falling back to the zone-less one.
    private static func decodeDate(forKey key: CodingKeys, using decoder: Decoder) throws -> Date? {
        if let isoKey = ISO8601DateKeys(canonicalKey: key),
           let isoContainer = try? decoder.container(keyedBy: ISO8601DateKeys.self),
           let date = try? isoContainer.decodeIfPresent(Date.self, forKey: isoKey) {
            return date
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        return try? container.decodeIfPresent(Date.self, forKey: key)
    }

    internal enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "stationuuid"
        case name
        case url
        case homepage
        case favicon
        case tags
        case country
        case state
        case language
        case votes
        case codec
        case bitrate
        case lastCheckOk = "lastcheckok"
        case lastCheckTime = "lastchecktime"
        case lastCheckTotal = "lastchecktotal"
        case lastCheckFailures = "lastcheckfailures"
        case lastCheckDuration = "lastcheckduration"
        case lastCheckError = "lastcheckerror"
        case lastChangeTime = "lastchangetime"
        case changeCounter = "changecounter"
        case creationTime = "creationtime"
        case urlResolved = "url_resolved"
    }
}

/// ISO 8601 twins the service adds to every timestamp it reports.
private enum ISO8601DateKeys: String, CodingKey {
    case lastCheckTime = "lastchecktime_iso8601"
    case lastChangeTime = "lastchangetime_iso8601"
    case creationTime = "creationtime_iso8601"

    init?(canonicalKey: StationObject.CodingKeys) {
        self.init(rawValue: canonicalKey.rawValue + "_iso8601")
    }
}
