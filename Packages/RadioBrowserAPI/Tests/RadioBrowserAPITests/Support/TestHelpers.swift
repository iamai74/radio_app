import Foundation
import Testing

/// Ordered `name=value` pairs of the query string, decoded back from percent encoding.
extension Array where Element == URLQueryItem {
    var pairs: [String] {
        map { "\($0.name)=\($0.value ?? "")" }
    }
}

extension URL {
    /// Ordered `name=value` pairs of the URL query, for exact URL assertions.
    var queryPairs: [String] {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems?.pairs ?? []
    }
}

/// URL of the last request the client was asked to perform.
func lastRequestURL(of client: MockNetworkClient) throws -> URL {
    let request = try #require(client.lastRequest, "Expected the endpoint to perform a request")
    return try #require(request.url, "Expected the recorded request to carry a URL")
}
