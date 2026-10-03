import Foundation

open class URLBuilder: Sendable {
    private let baseURL: String

    public init(baseURL: String = "https://de2.api.radio-browser.info") {
        self.baseURL = baseURL
    }

    func build(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.url
    }

    func build(endpoint: APIEndpoint, queryItems: [URLQueryItem]? = nil) -> URL? {
        let merged = (queryItems ?? endpoint.queryItems).isEmpty ? nil : (queryItems ?? endpoint.queryItems)
        return build(path: endpoint.path, queryItems: merged ?? [])
    }
}
