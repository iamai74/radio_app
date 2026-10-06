import Foundation

/// Walks the mirrors of a configuration and returns the payload of the first that accepts
/// the request.
///
/// Mirror selection is the only concern of this type: a failure that
/// ``APIError/isRetryable`` accepts moves the walk on to the next mirror, anything else
/// stops it. Building the request belongs to ``RequestBuilder``, decoding the answer to
/// ``RequestExecutor``.
internal struct FailoverTransport: Sendable {
    private let networkClient: NetworkClientProtocol
    private let requestBuilders: [RequestBuilder]

    /// - Parameters:
    ///   - networkClient: The transport performing the requests.
    ///   - configuration: The mirrors and request policy of every attempt.
    internal init(networkClient: NetworkClientProtocol, configuration: RadioBrowserConfiguration) {
        self.networkClient = networkClient
        self.requestBuilders = configuration.baseURLs.map { RequestBuilder(mirror: $0, configuration: configuration) }
    }

    /// Performs the request against the first mirror that accepts it.
    ///
    /// A mirror is skipped while the failure it reported is retryable, so an unreachable or
    /// briefly failing server costs one attempt instead of the whole call.
    /// - Parameters:
    ///   - endpoint: The route to perform.
    ///   - queryItems: Query items appended to the ones the route declares.
    /// - Returns: The response body of the mirror that answered.
    /// - Throws: `APIError` — `.invalidURL` when no mirror can form the request,
    ///   otherwise the failure of the last attempt.
    internal func fetchData(for endpoint: any EndpointDefinition, queryItems: [URLQueryItem]) async throws -> Data {
        var lastFailure: APIError?

        for (index, requestBuilder) in requestBuilders.enumerated() {
            let isLastMirror = index == requestBuilders.count - 1

            guard let request = requestBuilder.request(for: endpoint, queryItems: queryItems) else {
                // This mirror cannot form the URL; a later one still may, so the first
                // cause of the walk survives until a mirror actually answers.
                lastFailure = lastFailure ?? .invalidURL

                if isLastMirror {
                    break
                }

                continue
            }

            do {
                return try await networkClient.fetch(request: request)
            } catch {
                let failure = APIError.fromTransport(error)
                lastFailure = failure

                if isLastMirror || !failure.isRetryable {
                    throw failure
                }
            }
        }

        // Reached when no mirror produced a request URL. `RadioBrowserConfiguration`
        // always carries at least one mirror, so every reachable walk has a failure.
        throw lastFailure ?? .invalidURL
    }
}
