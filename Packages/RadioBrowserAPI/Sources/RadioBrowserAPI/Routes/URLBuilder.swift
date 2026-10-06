import Foundation

/// Turns an ``EndpointDefinition`` into the URL of a request.
public protocol URLBuilding: Sendable {
    /// Builds the URL of an endpoint.
    /// - Parameters:
    ///   - endpoint: The route to build.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The URL, or `nil` when the base URL or the path cannot form a valid request.
    func build(endpoint: any EndpointDefinition, queryItems: [URLQueryItem]) -> URL?
}

public extension URLBuilding {
    /// Builds the URL of an endpoint, without query items beyond the ones it declares.
    /// - Parameter endpoint: The route to build.
    /// - Returns: The URL, or `nil` when the base URL or the path cannot form a valid request.
    func build(endpoint: any EndpointDefinition) -> URL? {
        build(endpoint: endpoint, queryItems: [])
    }
}

/// Builds request URLs for the Radio Browser service.
///
/// The base URL is parsed and validated once, when the builder is created, and the path of
/// every route is percent encoded in exactly one place — `path` carries the raw values
/// (`hip hop`), the built URL carries `hip%20hop`.
public struct URLBuilder: URLBuilding {
    /// The service root, or `nil` when the configured base cannot form a request URL.
    ///
    /// Validated once so a bad mirror costs one failure at construction instead of a scheme
    /// and host check on every request.
    private let baseURL: URL?

    /// - Parameter baseURL: The service root, e.g. `https://de1.api.radio-browser.info`.
    public init(baseURL: String = RadioBrowserConfiguration.defaultBaseURL.absoluteString) {
        self.baseURL = Self.validated(baseURL)
    }

    /// - Parameter baseURL: The service root.
    public init(baseURL: URL) {
        self.baseURL = Self.validated(baseURL)
    }
    /// Builds the URL of a raw path.
    /// - Parameters:
    ///   - path: The path, starting with a slash; its segments are percent encoded here.
    ///   - queryItems: The query items to append.
    /// - Returns: The URL, or `nil` when the base URL cannot form a valid request.
    public func build(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard let baseURL else {
            return nil
        }

        var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        return components?.url
    }

    public func build(endpoint: any EndpointDefinition, queryItems: [URLQueryItem]) -> URL? {
        build(path: endpoint.path, queryItems: Self.merge(endpoint.queryItems, queryItems))
    }

    /// Parses the root once: only `http` and `https` roots with a host can carry a request.
    private static func validated(_ baseURL: String) -> URL? {
        guard let url = URL(string: baseURL) else {
            return nil
        }

        return validated(url)
    }

    private static func validated(_ baseURL: URL) -> URL? {
        guard let scheme = baseURL.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = baseURL.host,
              !host.isEmpty else {
            return nil
        }

        return baseURL
    }

    /// Query items declared by the endpoint, such as `q` for a search, are preserved and
    /// overridden by an item of the same name passed by the caller.
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
