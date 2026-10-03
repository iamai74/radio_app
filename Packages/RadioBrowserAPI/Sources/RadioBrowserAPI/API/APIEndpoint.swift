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
        case .stationByID(let id): return "/json/stations/\(id)"
        case .stationsSearch: return "/json/stations/search"
        case .stationsByCountry(let code): return "/json/stations/bycountry/\(code)"
        case .stationsByLanguage(let code): return "/json/stations/bylanguage/\(code)"
        case .stationsByTag(let tag): return "/json/stations/bytag/\(tag)"
        case .countries: return "/json/countries"
        case .countriesByFilter(let filter): return "/json/countries/\(filter)"
        case .languages: return "/json/languages"
        case .languagesByFilter(let filter): return "/json/languages/\(filter)"
        case .tags: return "/json/tags"
        case .tagsByFilter(let filter): return "/json/tags/\(filter)"
        case .codecs: return "/json/codecs"
        }
    }

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
