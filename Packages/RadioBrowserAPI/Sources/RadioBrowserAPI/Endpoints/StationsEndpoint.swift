import Foundation

/// Endpoint for interacting with radio stations.
final class StationsEndpoint: BaseEndpoint<StationObject>, StationsEndpointProtocol {
    // MARK: - Initialization

    public init(networkClient: NetworkClientProtocol) {
        super.init(networkClient: networkClient)
    }

    override init(networkClient: NetworkClientProtocol, urlBuilder: URLBuilder, jsonDecoder: JSONDecoderProtocol) {
        super.init(networkClient: networkClient, urlBuilder: urlBuilder, jsonDecoder: jsonDecoder)
    }

    // MARK: - StationsEndpointProtocol

    /// Fetches a list of radio stations based on the given criteria.
    /// - Parameters:
    ///   - country: The country to filter by, or nil for all countries.
    ///   - language: The language to filter by, or nil for all languages.
    ///   - tag: The tag to filter by, or nil for all tags.
    ///   - name: The name to filter by, or nil for all names.
    ///   - limit: The maximum number of results to return.
    ///   - offset: The offset to start retrieving results from.
    ///   - hideBreaks: Whether to hide breaks in the results.
    ///   - order: The field to order by.
    ///   - reverse: Whether the results should be in reverse order.
    /// - Returns: Array of Station objects matching the criteria
    /// - Throws: APIError if request fails
    public func getStations(
        country: String? = nil,
        language: String? = nil,
        tag: String? = nil,
        name: String? = nil,
        limit: Int = 100,
        offset: Int = 0,
        hideBreaks: Bool = false,
        order: String = "name",
        reverse: Bool = false
    ) async throws -> [any Station] {
        let queryItems = makeQueryItems(
            country: country,
            language: language,
            tag: tag,
            name: name,
            limit: limit,
            offset: offset,
            hideBreaks: hideBreaks,
            order: order,
            reverse: reverse
        )

        return try await fetch(endpoint: .stations, queryItems: queryItems, exposing: { $0 })
    }

    /// Fetches all radio stations.
    /// - Returns: Array of Station objects
    /// - Throws: APIError if request fails
    public func getAllStations() async throws -> [any Station] {
        try await fetch(endpoint: .stations, exposing: { $0 })
    }

    /// Fetches a specific station by its ID.
    ///
    /// Radio Browser exposes no single station route, so the request goes to
    /// `/json/stations/byuuid/{id}`, which answers with a list.
    /// - Parameter id: The station's unique identifier
    /// - Returns: The station with the specified ID, or `nil` when the service knows no such station
    /// - Throws: APIError if request fails
    public func getStation(byID id: String) async throws -> (any Station)? {
        try await fetchFirst(endpoint: .stationByID(id: id))
    }

    /// Searches for stations matching a query string.
    /// - Parameters:
    ///   - query: The search query
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of Station objects matching the query
    /// - Throws: APIError if request fails
    public func searchStations(query: String, limit: Int) async throws -> [any Station] {
        var queryItems: [URLQueryItem] = []
        if limit > 0 {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        return try await fetch(endpoint: .stationsSearch(query: query), queryItems: queryItems, exposing: { $0 })
    }

    /// Fetches stations from a specific country.
    /// - Parameters:
    ///   - country: Country code filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects from the specified country
    /// - Throws: APIError if request fails
    public func getStationsByCountry(_ country: String, limit: Int) async throws -> [any Station] {
        let queryItems = limit > 0 ? [URLQueryItem(name: "limit", value: "\(limit)")] : []
        return try await fetch(endpoint: .stationsByCountry(countryCode: country), queryItems: queryItems, exposing: { $0 })
    }

    /// Fetches stations in a specific language.
    /// - Parameters:
    ///   - language: Language code filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects in the specified language
    /// - Throws: APIError if request fails
    public func getStationsByLanguage(_ language: String, limit: Int) async throws -> [any Station] {
        let queryItems = limit > 0 ? [URLQueryItem(name: "limit", value: "\(limit)")] : []
        return try await fetch(endpoint: .stationsByLanguage(languageCode: language), queryItems: queryItems, exposing: { $0 })
    }

    /// Fetches stations with a specific tag.
    /// - Parameters:
    ///   - tag: Tag filter
    ///   - limit: Maximum number of stations to return
    /// - Returns: Array of Station objects with the specified tag
    /// - Throws: APIError if request fails
    public func getStationsByTag(_ tag: String, limit: Int) async throws -> [any Station] {
        let queryItems = limit > 0 ? [URLQueryItem(name: "limit", value: "\(limit)")] : []
        return try await fetch(endpoint: .stationsByTag(tag: tag), queryItems: queryItems, exposing: { $0 })
    }

    // MARK: - Private helpers

    // swiftlint:disable function_parameter_count
    private func makeQueryItems(
        country: String?,
        language: String?,
        tag: String?,
        name: String?,
        limit: Int,
        offset: Int,
        hideBreaks: Bool,
        order: String,
        reverse: Bool
    ) -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let country = country, !country.isEmpty {
            items.append(URLQueryItem(name: "country", value: country))
        }
        if let language = language, !language.isEmpty {
            items.append(URLQueryItem(name: "language", value: language))
        }
        if let tag = tag, !tag.isEmpty {
            items.append(URLQueryItem(name: "tag", value: tag))
        }
        if let name = name, !name.isEmpty {
            items.append(URLQueryItem(name: "name", value: name))
        }

        items.append(URLQueryItem(name: "limit", value: "\(limit)"))
        items.append(URLQueryItem(name: "offset", value: "\(offset)"))
        items.append(URLQueryItem(name: "hide_breaks", value: hideBreaks ? "true" : "false"))
        items.append(URLQueryItem(name: "order", value: order))
        items.append(URLQueryItem(name: "reverse", value: reverse ? "true" : "false"))

        return items
    }
    // swiftlint:enable function_parameter_count
}
