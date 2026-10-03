import Foundation

/// Builds request URLs for the Radio Browser service.
open class URLBuilder: Sendable {
    private let baseURL: String

    /// - Parameter baseURL: The service root, e.g. `https://de1.api.radio-browser.info`.
    public init(baseURL: String = "https://de2.api.radio-browser.info") {
        self.baseURL = baseURL
    }

    /// - Parameters:
    ///   - path: The endpoint path, starting with a slash.
    ///   - queryItems: The query items to append.
    /// - Returns: The URL, or `nil` when the base URL or the path cannot form a valid request.
    func build(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard var components = URLComponents(string: baseURL + path),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = components.host,
              !host.isEmpty else {
            return nil
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems

        return components.url
    }

    /// Builds the URL of an endpoint.
    ///
    /// Query items declared by the endpoint, such as `q` for a search, are preserved and
    /// overridden by an item of the same name passed by the caller.
    func build(endpoint: APIEndpoint, queryItems: [URLQueryItem] = []) -> URL? {
        build(path: endpoint.path, queryItems: Self.merge(endpoint.queryItems, queryItems))
    }

    private static func merge(_ endpointItems: [URLQueryItem], _ items: [URLQueryItem]) -> [URLQueryItem] {
        var merged = endpointItems

        for item in items {
            if let index = merged.firstIndex(where: { $0.name == item.name }) {
                merged[index] = item
            } else {
                merged.append(item)
            }
        }

        return merged
    }
}
