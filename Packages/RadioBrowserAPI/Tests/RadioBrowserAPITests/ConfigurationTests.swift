import Foundation
import Testing
@testable import RadioBrowserAPI

/// The invariants `RadioBrowserConfiguration` promises to the failover: it always carries
/// at least one mirror, and the derived `baseURL` points at the first of them.
struct ConfigurationTests {

    // MARK: - Mirrors

    @Test
    func defaultsPointAtThePublishedMirrors() {
        let configuration = RadioBrowserConfiguration()

        #expect(configuration.baseURLs == RadioBrowserConfiguration.defaultBaseURLs)
        #expect(configuration.baseURL == RadioBrowserConfiguration.defaultBaseURL)
        #expect(configuration.baseURL == configuration.baseURLs.first)
    }

    /// An emptied mirror list would reach the transport as "no attempts made"; the
    /// initialiser falls back instead, so the failover always has a mirror to walk.
    @Test
    func emptyMirrorListFallsBackToThePublishedMirrors() {
        let configuration = RadioBrowserConfiguration(baseURLs: [])

        #expect(configuration.baseURLs == RadioBrowserConfiguration.defaultBaseURLs)
        #expect(configuration.baseURL == RadioBrowserConfiguration.defaultBaseURL)
    }

    @Test
    func customMirrorsAreKeptInOrder() throws {
        let first = try #require(URL(string: "https://mirror-one.example.com"))
        let second = try #require(URL(string: "https://mirror-two.example.com"))
        let configuration = RadioBrowserConfiguration(baseURLs: [first, second])

        #expect(configuration.baseURLs == [first, second])
        #expect(configuration.baseURL == first)
    }

    /// A mirror the request builder cannot use is kept: deciding which roots carry a
    /// request belongs to `URLBuilder`, not to the configuration.
    @Test
    func anUnusableMirrorIsStillTheFirstMirror() throws {
        let ftp = try #require(URL(string: "ftp://mirror-one.example.com"))
        let configuration = RadioBrowserConfiguration(baseURLs: [ftp])

        #expect(configuration.baseURL == ftp)
    }

    // MARK: - Request policy

    @Test
    func requestPolicyCanBeOverriddenPerCall() throws {
        let mirror = try #require(URL(string: "https://mirror-one.example.com"))
        let configuration = RadioBrowserConfiguration(
            baseURLs: [mirror],
            userAgent: "MyRadio/2.0",
            timeout: 5,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        #expect(configuration.userAgent == "MyRadio/2.0")
        #expect(configuration.timeout == 5)
        #expect(configuration.cachePolicy == .reloadIgnoringLocalCacheData)
    }

    @Test
    func requestPolicyDefaultsMatchTheDocumentation() {
        let configuration = RadioBrowserConfiguration()

        #expect(configuration.userAgent == "RadioApp/1.0")
        #expect(configuration.timeout == 30)
        #expect(configuration.cachePolicy == .useProtocolCachePolicy)
    }

    // MARK: - Value semantics

    @Test
    func configurationsAreValuesThatCompareByContent() {
        #expect(RadioBrowserConfiguration() == RadioBrowserConfiguration())

        var changed = RadioBrowserConfiguration()
        changed.timeout = 10

        #expect(changed != RadioBrowserConfiguration())
        #expect(RadioBrowserConfiguration().timeout == 30)
    }

    /// Compile time only: the call type-checks only while `T` is `Sendable`, which keeps a
    /// configuration shareable across tasks an expectation cannot cover at runtime.
    @Test
    func configurationIsSendable() {
        requireSendable(RadioBrowserConfiguration.self)
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
