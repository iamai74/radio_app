import Foundation

enum APIEndpoint: String, Sendable {
    case stations = "/json/stations"
    case stationByID = "/json/stations/%@"
    case stationsSearch = "/json/stations/search"
    case stationsByCountry = "/json/stations/bycountry/%@"
    case stationsByLanguage = "/json/stations/bylanguage/%@"
    case stationsByTag = "/json/stations/bytag/%@"
    case countries = "/json/countries"
    case countriesByFilter = "/json/countries/%@"
    case languages = "/json/languages"
    case languagesByFilter = "/json/languages/%@"
    case tags = "/json/tags"
    case tagsByFilter = "/json/tags/%@"
    case codecs = "/json/codecs"
    
    public func path(with argument: String? = nil) -> String {
        if let arg = argument {
            return String(format: rawValue, arg)
        }
        return rawValue
    }
}