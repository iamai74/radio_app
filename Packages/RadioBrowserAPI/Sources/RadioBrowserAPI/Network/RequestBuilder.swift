import Foundation

/// Builds the `URLRequest` of one attempt against one mirror.
///
/// Every request policy of the ``RadioBrowserConfiguration`` is applied here — URL, query,
/// timeout, cache policy and the `User-Agent` the service asks for — so the transport
/// performs exactly the request it is handed. A custom ``NetworkClientProtocol`` therefore
/// sees the same request the default client would, and the whole policy is asserted in one
/// place instead of being spread across the client and the endpoints.
internal struct RequestBuilder: Sendable {
    private let urlBuilder: URLBuilder
    private let userAgent: String
    private let timeout: TimeInterval
    private let cachePolicy: URLRequest.CachePolicy

    /// - Parameters:
    ///   - mirror: The base URL of the mirror this builder targets.
    ///   - configuration: The request policy every attempt of the client shares.
    internal init(mirror: URL, configuration: RadioBrowserConfiguration) {
        self.urlBuilder = URLBuilder(baseURL: mirror)
        self.userAgent = configuration.userAgent
        self.timeout = configuration.timeout
        self.cachePolicy = configuration.cachePolicy
    }

    /// The request for a route, or `nil` when this mirror and the route cannot form a URL.
    /// - Parameters:
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    func request(for endpoint: any EndpointDefinition, queryItems: [URLQueryItem]) -> URLRequest? {
        guard let url = urlBuilder.build(endpoint: endpoint, queryItems: queryItems) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.cachePolicy = cachePolicy
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        return request
    }
}
