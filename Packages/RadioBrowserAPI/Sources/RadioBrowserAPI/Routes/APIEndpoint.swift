import Foundation

/// The routes of the Radio Browser service used by this package.
///
/// A route is a value, not a case of a closed enum: `APIEndpoint(path:)` builds any route
/// the service exposes, so new ones do not require changing this type.
///
/// Paths carry the raw filter values — `hip hop`, not `hip%20hop`: percent encoding is the
/// job of the URL builder, which sees every route of a request.
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
        APIEndpoint(path: "/json/stations/byuuid/\(id)")
    }

    /// Stations matching a free text query.
    public static func stationsSearch(query: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/search", queryItems: [URLQueryItem(name: "q", value: query)])
    }

    /// Stations broadcasting from a country.
    public static func stationsByCountry(countryCode: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/bycountry/\(countryCode)")
    }

    /// Stations broadcasting in a language.
    public static func stationsByLanguage(languageCode: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/bylanguage/\(languageCode)")
    }

    /// Stations carrying a tag.
    public static func stationsByTag(tag: String) -> APIEndpoint {
        APIEndpoint(path: "/json/stations/bytag/\(tag)")
    }

    public static let countries = APIEndpoint(path: "/json/countries")

    public static func countriesByFilter(filter: String) -> APIEndpoint {
        filtered("countries", filter)
    }

    public static let languages = APIEndpoint(path: "/json/languages")

    public static func languagesByFilter(filter: String) -> APIEndpoint {
        filtered("languages", filter)
    }

    public static let tags = APIEndpoint(path: "/json/tags")

    public static func tagsByFilter(filter: String) -> APIEndpoint {
        filtered("tags", filter)
    }

    public static let codecs = APIEndpoint(path: "/json/codecs")

    /// The `/{resource}/{filter}` route the service offers for the counted resources.
    private static func filtered(_ resource: String, _ filter: String) -> APIEndpoint {
        APIEndpoint(path: "/json/\(resource)/\(filter)")
    }
}
