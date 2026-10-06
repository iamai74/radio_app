import Foundation

/// Everything the client needs to talk to a Radio Browser service.
///
/// The service is run by volunteers as a set of interchangeable mirrors, so a
/// configuration carries more than one base URL: the endpoints try them in order and
/// fail over while an attempt is still retryable.
public struct RadioBrowserConfiguration: Sendable, Equatable {
    /// The mirrors to query, in the order they are tried.
    ///
    /// Never empty: an empty list passed to the initialiser falls back to
    /// ``defaultBaseURLs``, so the failover always has a mirror to walk. The field is
    /// immutable because the invariant has to survive every mutation of the value — an
    /// emptied mirror list would otherwise reach the transport as "no attempts made".
    public let baseURLs: [URL]

    /// The `User-Agent` the service expects from its clients.
    public var userAgent: String

    /// The timeout applied to every request, in seconds.
    public var timeout: TimeInterval

    /// The cache policy applied to every request.
    public var cachePolicy: URLRequest.CachePolicy

    /// - Parameters:
    ///   - baseURLs: The mirrors to query, in the order they are tried. An empty list falls
    ///     back to ``defaultBaseURLs``.
    ///   - userAgent: The `User-Agent` the service expects from its clients.
    ///   - timeout: The timeout applied to every request, in seconds.
    ///   - cachePolicy: The cache policy applied to every request.
    public init(
        baseURLs: [URL] = RadioBrowserConfiguration.defaultBaseURLs,
        userAgent: String = "RadioApp/1.0",
        timeout: TimeInterval = 30,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) {
        self.baseURLs = baseURLs.isEmpty ? Self.defaultBaseURLs : baseURLs
        self.userAgent = userAgent
        self.timeout = timeout
        self.cachePolicy = cachePolicy
    }

    /// The first mirror, i.e. the one the failover starts with.
    public var baseURL: URL {
        // Non-empty by construction: the initialiser falls back to the published mirrors.
        baseURLs[0]
    }

    /// The configuration the package ships with: the mirrors published by the project, a
    /// neutral user agent and a 30 second timeout.
    public static let `default` = RadioBrowserConfiguration()

    /// Mirrors published by the Radio Browser project; `de2` answers first today, `de1`
    /// takes over while it is unreachable.
    public static let defaultBaseURLs: [URL] = [
        URL(string: "https://de2.api.radio-browser.info"),
        URL(string: "https://de1.api.radio-browser.info")
    ].compactMap { $0 }

    /// The first mirror of ``defaultBaseURLs``, i.e. where the default failover starts.
    public static let defaultBaseURL: URL = defaultBaseURLs[0]
}
