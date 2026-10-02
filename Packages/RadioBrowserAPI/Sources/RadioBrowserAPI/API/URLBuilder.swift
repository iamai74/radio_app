import Foundation

final class URLBuilder: Sendable {
    private let baseURL: String

    init(baseURL: String = "https://de2.api.radio-browser.info") {
        self.baseURL = baseURL
    }

    func build(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.url
    }

    func build(endpoint: APIEndpoint, argument: String? = nil, queryItems: [URLQueryItem] = []) -> URL? {
        build(path: endpoint.path(with: argument), queryItems: queryItems)
    }
}
