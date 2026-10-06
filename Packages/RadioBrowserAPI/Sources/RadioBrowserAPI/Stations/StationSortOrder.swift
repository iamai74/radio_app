import Foundation

/// The fields the service can order a station list by.
///
/// Typed instead of a raw `String` so a sort key cannot be misspelled at a call site;
/// every case maps to the value the API expects.
public enum StationSortOrder: String, Sendable, Equatable, CaseIterable {
    case name
    case url
    case homepage
    case favicon
    case country
    case state
    case language
    case tags
    case votes
    case clicks
    case bitrate
    case codec
    case lastCheckTime = "lastchecktime"
    case clickTimestamp = "clicktimestamp"
    case lastChangeTime = "lastchangetime"
    case creationTime = "creationtime"
    case random
}
