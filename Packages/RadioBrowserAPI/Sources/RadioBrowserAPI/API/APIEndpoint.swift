import Foundation

/// The routes of the Radio Browser service used by this package.
///
/// A route is a value, not a case of a closed enum: `APIEndpoint(path:)` builds any route
/// the service exposes, so new ones do not require changing this type.
public struct APIEndpoint: EndpointDefinition, Equatable {
    public let path: String
    public let queryItems: [URLQueryItem]

    /// - Parameters:
    ///   - path: The API path, starting with a slash.
    ///   - queryItems: The query items the route requires.
    public init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }

    /// Every radio station, filtered through the query items of the request.
    public static let stations = APIEndpoint(path: "/json/stations")

    /// A single station. Radio Browser has no single object route: this path answers with
    /// a list holding the requested station, and an empty list when it is unknown.
    public static func stationByID(id: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/byuuid/\(pathSegment(id))")
    }

    /// Stations matching a free text query.
    public static func stationsSearch(query: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/search", queryItems: [URLQueryItem(name: "q", value: query)])
    }

    /// Stations broadcasting from a country.
    public static func stationsByCountry(countryCode: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/bycountry/\(pathSegment(countryCode))")
    }

    /// Stations broadcasting in a language.
    public static func stationsByLanguage(languageCode: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/bylanguage/\(pathSegment(languageCode))")
    }

    /// Stations carrying a tag.
    public static func stationsByTag(tag: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/bytag/\(pathSegment(tag))")
    }

    public static let countries = APIEndpoint(path: "/json/countries")

    public static func countriesByFilter(filter: String) -> APIEndpoint {
        APIEndpoint(path: "/json/countries/\(pathSegment(filter))")
    }

    public static let languages = APIEndpoint(path: "/json/languages")

    public static func languagesByFilter(filter: String) -> APIEndpoint {
        APIEndpoint(path: "/json/languages/\(pathSegment(filter))")
    }

    public static let tags = APIEndpoint(path: "/json/tags")

    public static func tagsByFilter(filter: String) -> APIEndpoint {
        APIEndpoint(path: "/json/tags/\(pathSegment(filter))")
    }

    public static let codecs = APIEndpoint(path: "/json/codecs")

    /// Percent encodes a value interpolated into a path, so filters such as `hip hop`
    /// reach the service as a single path segment. Exposed for callers building their own
    /// routes.
    public static func pathSegment(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: pathSegmentAllowed) ?? value
    }

    private static let pathSegmentAllowed: CharacterSet = {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/?#")
        return allowed
    }()
}
