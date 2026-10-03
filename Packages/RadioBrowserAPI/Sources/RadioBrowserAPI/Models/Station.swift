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

    /// Tags associated with the station.
    var tags: [String]? { get }

    /// The country where the station is located.
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
    var lastCheckTotal: Int { get }

    /// The number of failures during the last check.
    var lastCheckFailures: Int { get }

    /// The duration of the last check in milliseconds.
    var lastCheckDuration: Int { get }

    /// Error message from the last check, if any.
    var lastCheckError: String? { get }

    /// The time when the station was last modified.
    var lastChangeTime: Date? { get }

    /// A counter for how many changes have been made to this station.
    var changeCounter: Int { get }

    /// The creation time of this station.
    var creationTime: Date? { get }

    /// The resolved URL after checking the station's stream.
    var urlResolved: String? { get }
}

/// An internal struct implementing the Station protocol with Codable conformance.
internal struct StationObject: Codable, Station {
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
    public let lastCheckTotal: Int
    public let lastCheckFailures: Int
    public let lastCheckDuration: Int
    public let lastCheckError: String?
    public let lastChangeTime: Date?
    public let changeCounter: Int
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
    init(
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
        lastCheckOk: Bool,
        lastCheckTime: Date? = nil,
        lastCheckTotal: Int = 0,
        lastCheckFailures: Int = 0,
        lastCheckDuration: Int = 0,
        lastCheckError: String? = nil,
        lastChangeTime: Date? = nil,
        changeCounter: Int = 0,
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

    private enum CodingKeys: String, CodingKey {
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
