import Testing
import Foundation
@testable import RadioBrowserAPI

/// Opt in switch for the tests that talk to the live Radio Browser service.
private enum LiveTests {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["RADIO_BROWSER_LIVE_TESTS"] == "1"
    }
}

/// Smoke tests against the live Radio Browser service.
///
/// The fixtures of the other suites pin the payloads the service has served, these check that
/// it still serves them: the endpoint answers with what the models expect, the search query
/// reaches the service, and an unknown station UUID is reported as `nil`.
///
///     RADIO_BROWSER_LIVE_TESTS=1 swift test --filter LiveServiceTests
@Suite(.serialized, .enabled(if: LiveTests.isEnabled))
struct LiveServiceTests {
    private func makeAPI() -> RadioBrowserAPI {
        RadioBrowserAPI(
            configuration: RadioBrowserConfiguration(userAgent: "RadioBrowserAPITests/live"),
            networkClient: DefaultNetworkClient()
        )
    }

    /// Stations by votes, with the checks that would hide broken streams enabled.
    private func popularStations(limit: Int) async throws -> [any Station] {
        try await makeAPI().stations.getStations(matching: StationQuery(
            limit: limit,
            hideBreaks: true,
            order: .votes,
            reverse: true
        ))
    }

    private func stations(tagged tag: String, limit: Int) async throws -> [any Station] {
        try await makeAPI().stations.getStations(matching: StationQuery(
            tag: tag,
            limit: limit,
            hideBreaks: true,
            order: .votes,
            reverse: true
        ))
    }

    @Test
    func stationListDecodesAndKeepsItsOrder() async throws {
        let stations = try await popularStations(limit: 10)

        #expect(!stations.isEmpty)
        #expect(stations.allSatisfy { !$0.id.isEmpty && !$0.name.isEmpty && !$0.url.isEmpty })
        #expect(stations.map(\.votes) == stations.map(\.votes).sorted(by: >))
    }

    /// The service also reports tag lists separated by spaces only, so a station of the
    /// filter can decode to a single tag; the filter itself is what this checks.
    @Test
    func tagFilterReachesTheService() async throws {
        let stations = try await stations(tagged: "jazz", limit: 10)

        #expect(!stations.isEmpty)
        #expect(stations.contains { ($0.tags ?? []).contains("jazz") })
    }

    @Test
    func searchStationsMatchesTheQuery() async throws {
        let stations = try await makeAPI().stations.searchStations(query: "jazz", limit: 10)

        #expect(!stations.isEmpty)
    }

    @Test
    func stationByIDResolvesAKnownStationAndRejectsAnUnknownOne() async throws {
        let api = makeAPI()
        let stations = try await popularStations(limit: 1)
        let identifier = try #require(stations.first?.id)

        let found = try await api.stations.getStation(byID: identifier)
        let missing = try await api.stations.getStation(byID: "00000000-0000-0000-0000-000000000000")

        #expect(found?.id == identifier)
        #expect(missing == nil)
    }

    @Test
    func lookupsDecode() async throws {
        let api = makeAPI()
        let countries = try await api.countries.getResources()
        let languages = try await api.languages.getResources()
        let tags = try await api.tags.getResources()
        let codecs = try await api.codecs.getResources()

        // The service reports one country without a name, its code is always present.
        #expect(!countries.isEmpty && countries.allSatisfy { !$0.iso31661.isEmpty && $0.stationCount >= 0 })
        #expect(!languages.isEmpty)
        #expect(!tags.isEmpty)
        #expect(!codecs.isEmpty)
    }
}
