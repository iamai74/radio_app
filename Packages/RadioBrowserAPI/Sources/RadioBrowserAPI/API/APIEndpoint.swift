import Foundation

/// Represents all available API endpoints for the Radio Browser service.
public enum APIEndpoint: Sendable {
    case stations
    case stationByID(id: String)
    case stationsSearch(query: String)
    case stationsByCountry(countryCode: String)
    case stationsByLanguage(languageCode: String)
    case stationsByTag(tag: String)
    case countries
    case countriesByFilter(filter: String)
    case languages
    case languagesByFilter(filter: String)
    case tags
    case tagsByFilter(filter: String)
    case codecs

    /// Returns the API path for the endpoint.
    internal var path: String {
        switch self {
        case .stations: return "/json/stations"
        case .stationByID(let id): return "/json/stations/byuuid/\(Self.pathSegment(id))"
        case .stationsSearch: return "/json/stations/search"
        case .stationsByCountry(let code): return "/json/stations/bycountry/\(Self.pathSegment(code))"
        case .stationsByLanguage(let code): return "/json/stations/bylanguage/\(Self.pathSegment(code))"
        case .stationsByTag(let tag): return "/json/stations/bytag/\(Self.pathSegment(tag))"
        case .countries: return "/json/countries"
        case .countriesByFilter(let filter): return "/json/countries/\(Self.pathSegment(filter))"
        case .languages: return "/json/languages"
        case .languagesByFilter(let filter): return "/json/languages/\(Self.pathSegment(filter))"
        case .tags: return "/json/tags"
        case .tagsByFilter(let filter): return "/json/tags/\(Self.pathSegment(filter))"
        case .codecs: return "/json/codecs"
        }
    }

    /// Percent encodes a value interpolated into the path, so filters such as `hip hop`
    /// reach the service as a single path segment.
    private static func pathSegment(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: pathSegmentAllowed) ?? value
    }

    private static let pathSegmentAllowed: CharacterSet = {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/?#")
        return allowed
    }()

    /// Returns the query items for the endpoint if applicable.
    internal var queryItems: [URLQueryItem] {
        switch self {
        case .stationsSearch(let query):
            return [URLQueryItem(name: "q", value: query)]
        default:
            return []
        }
    }
}
