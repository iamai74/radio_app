import Testing
import Foundation
@testable import RadioBrowserAPI

/// Tests for the JSON contract of the models.
///
/// The fixtures in `Mocks/Data` mirror the payloads of the Radio Browser service:
/// `stations-live.json` is a verbatim capture of `GET /json/stations`, the others cover the
/// field variants the service mixes (`lastcheckok` as `1`/`0`/string, `tags` as a comma
/// separated string, empty strings instead of `null`, timestamps in two layouts).
struct ModelDecodingTests {

    // MARK: - Station

    @Test
    func stationDecodesEveryMappedField() throws {
        let station = try DefaultJSONDecoder().decode(StationObject.self, from: MockData.json(named: "station"))

        #expect(station.id == "7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60")
        #expect(station.name == "Test Radio Station")
        #expect(station.url == "https://example.com/stream")
        #expect(station.urlResolved == "https://example.com/resolved")
        #expect(station.homepage == "https://example.com")
        #expect(station.favicon == "https://example.com/favicon.png")
        #expect(station.country == "United States")
        #expect(station.state == "California")
        #expect(station.language == "english")
        #expect(station.votes == 42)
        #expect(station.codec == "MP3")
        #expect(station.bitrate == 128)
        #expect(station.lastCheckOk)
    }

    @Test
    func stationDecodesCountersAndTimestamps() throws {
        let station = try DefaultJSONDecoder().decode(StationObject.self, from: MockData.json(named: "station"))

        // `lastchecktime_iso8601` wins over the zone-less twin of the same instant.
        #expect(station.lastCheckTime == date("2023-01-01T12:00:00Z"))
        #expect(station.lastCheckTotal == 100)
        #expect(station.lastCheckFailures == 5)
        #expect(station.lastCheckDuration == 200)
        #expect(station.lastCheckError == nil)
        #expect(station.lastChangeTime == date("2023-01-01T12:00:00Z"))
        #expect(station.changeCounter == 10)
        #expect(station.creationTime == date("2023-01-01T12:00:00Z"))
    }

    @Test
    func stationDecodesCommaSeparatedTags() throws {
        let station = try DefaultJSONDecoder().decode(StationObject.self, from: MockData.json(named: "station"))

        // The service sends a comma separated string and keeps the spaces inside a tag.
        #expect(station.tags == ["rock", "classic rock"])
    }

    @Test
    func stationListPayloadCoversServiceVariants() throws {
        let stations = try DefaultJSONDecoder().decode([StationObject].self, from: MockData.json(named: "stations"))

        #expect(stations.count == 3)
        #expect(stations.map(\.id) == ["7c1f5a2e-6b6d-4f9a-9d0f-2b1c3d4e5f60", "second-station-id", "third-station-id"])

        // Counters and `creationtime` are absent from the list endpoints.
        #expect(stations[1].lastCheckTotal == nil)
        #expect(stations[1].lastCheckFailures == nil)
        #expect(stations[1].lastCheckDuration == nil)
        #expect(stations[1].changeCounter == nil)
        #expect(stations[1].creationTime == nil)

        // Empty strings stand in for missing values.
        #expect(stations[1].homepage == nil)
        #expect(stations[1].favicon == nil)
        #expect(stations[1].state == nil)
        #expect(stations[1].urlResolved == nil)
        #expect(stations[1].tags == nil)

        // `lastcheckok` arrives as `1`/`0`.
        #expect(stations[0].lastCheckOk)
        #expect(!stations[1].lastCheckOk)
    }

    @Test
    func stationDecodesTagsArrayAndTypedStrings() throws {
        let stations = try DefaultJSONDecoder().decode([StationObject].self, from: MockData.json(named: "stations"))
        let station = try #require(stations.last)

        #expect(station.tags == ["jazz", "blues"])
        #expect(station.votes == 17)
        #expect(station.bitrate == 320)
        #expect(station.lastCheckOk)
        #expect(station.lastCheckTime == date("2023-01-01T12:00:00+01:00"))
    }

    @Test
    func stationDecodesZoneLessTimestampsAsUTC() throws {
        let payload = Data("""
        {
            "stationuuid": "zone-less",
            "name": "Zone Less",
            "url": "https://example.com/stream",
            "country": "United States",
            "votes": 1,
            "lastcheckok": 1,
            "lastchecktime": "2023-01-01 12:00:00"
        }
        """.utf8)

        let station = try DefaultJSONDecoder().decode(StationObject.self, from: payload)

        #expect(station.lastCheckTime == date("2023-01-01T12:00:00Z"))
    }

    /// `lastcheckok` is a number in list payloads, a boolean elsewhere and a string in some
    /// legacy mirrors of the API.
    @Test(arguments: [
        ("1", true),
        ("0", false),
        ("true", true),
        ("false", false),
        ("\"true\"", true),
        ("\"0\"", false)
    ])
    func lastCheckOkAcceptsEveryServiceRepresentation(jsonValue: String, expected: Bool) throws {
        let station = try decodeStation(lastCheckOk: jsonValue)

        #expect(station.lastCheckOk == expected)
    }

    @Test
    func lastCheckOkDefaultsToFalseWhenAbsent() throws {
        let payload = Data("""
        {
            "stationuuid": "unchecked",
            "name": "Unchecked",
            "url": "https://example.com/stream",
            "country": "United States",
            "votes": 1
        }
        """.utf8)

        #expect(try DefaultJSONDecoder().decode(StationObject.self, from: payload).lastCheckOk == false)
    }

    /// The service keeps changing its timestamp layouts, so an unreadable one costs the
    /// timestamp but not the station.
    @Test
    func unsupportedTimestampIsDroppedInsteadOfFailingTheStation() throws {
        let payload = Data("""
        {
            "stationuuid": "broken",
            "name": "Broken",
            "url": "https://example.com/stream",
            "country": "United States",
            "votes": 1,
            "lastchecktime": "01/01/2023 12:00"
        }
        """.utf8)

        let station = try DefaultJSONDecoder().decode(StationObject.self, from: payload)

        #expect(station.id == "broken")
        #expect(station.lastCheckTime == nil)
    }

    @Test
    func stationDecodingFailsWithoutMandatoryFields() {
        let payload = Data(#"{"stationuuid": "only-an-id"}"#.utf8)

        #expect(throws: DecodingError.self) {
            try DefaultJSONDecoder().decode(StationObject.self, from: payload)
        }
    }

    /// Every key the model maps has to be present in the fixture, so a newly added model
    /// property cannot slip through without decoding coverage.
    @Test
    func stationFixtureCoversEveryMappedKey() throws {
        let original = try #require(try JSONSerialization.jsonObject(with: try MockData.json(named: "station")) as? [String: Any])
        let fixtureKeys = Set(original.keys)
        let unmapped = StationObject.CodingKeys.allCases.map(\.rawValue).filter { !fixtureKeys.contains($0) }

        #expect(unmapped.isEmpty, "Fixture 'station.json' is missing: \(unmapped)")
    }

    // MARK: - Captured live payload

    @Test
    func capturedStationListDecodes() throws {
        let stations = try DefaultJSONDecoder().decode([StationObject].self, from: MockData.json(named: "stations-live"))

        #expect(stations.count == 3)

        let first = try #require(stations.first)
        #expect(first.id == "78012206-1aa1-11e9-a80b-52543be04c81")
        #expect(first.name == "MANGORADIO")
        #expect(first.country == "Germany")
        #expect(first.state == "Rheinland-Pfalz")
        #expect(first.language == "english,german")
        #expect(first.votes == 826_536)
        #expect(first.codec == "MP3")
        #expect(first.bitrate == 128)
        #expect(first.lastCheckOk)
        #expect(first.lastCheckTime == date("2026-09-30T22:24:55Z"))
        #expect(first.lastChangeTime == date("2026-09-30T22:24:51Z"))
        #expect(first.tags == ["music", "variety"])

        // The service omits the check counters on the list endpoint.
        #expect(first.lastCheckTotal == nil)
        #expect(first.creationTime == nil)

        // Tags are also reported space separated, and empty strings stand in for nulls.
        #expect(stations[1].tags == ["club dance electronic house trance"])
        #expect(stations[1].state == nil)
    }

    // MARK: - Lookups

    @Test
    func countryDecoding() throws {
        let country = try DefaultJSONDecoder().decode(CountryObject.self, from: MockData.json(named: "country"))

        #expect(country.name == "United States")
        #expect(country.iso31661 == "US")
        #expect(country.stationCount == 1500)
    }

    @Test
    func languageDecoding() throws {
        let language = try DefaultJSONDecoder().decode(LanguageObject.self, from: MockData.json(named: "language"))

        #expect(language.name == "English")
        #expect(language.stationCount == 3200)
    }

    @Test
    func tagDecoding() throws {
        let tag = try DefaultJSONDecoder().decode(TagObject.self, from: MockData.json(named: "tag"))

        #expect(tag.name == "rock")
        #expect(tag.stationCount == 500)
    }

    @Test
    func codecDecoding() throws {
        let codec = try DefaultJSONDecoder().decode(CodecObject.self, from: MockData.json(named: "codec"))

        #expect(codec.name == "MP3")
        #expect(codec.stationCount == 2500)
    }

    @Test
    func listPayloadsDecodeInOrder() throws {
        let decoder = DefaultJSONDecoder()

        #expect(try decoder.decode([CountryObject].self, from: MockData.json(named: "countries")).map(\.iso31661) == ["US", "DE"])
        #expect(try decoder.decode([LanguageObject].self, from: MockData.json(named: "languages")).map(\.name) == ["English", "German"])
        #expect(try decoder.decode([TagObject].self, from: MockData.json(named: "tags")).map(\.name) == ["rock", "jazz"])
        #expect(try decoder.decode([CodecObject].self, from: MockData.json(named: "codecs")).map(\.name) == ["MP3", "AAC"])
    }

    @Test
    func emptyListDecodesToEmptyArray() throws {
        #expect(try DefaultJSONDecoder().decode([StationObject].self, from: MockData.json(named: "stations-empty")).isEmpty)
    }

    // MARK: - Helpers

    private func date(_ value: String) -> Date? {
        ISO8601DateFormatter().date(from: value)
    }

    private func decodeStation(lastCheckOk value: String) throws -> StationObject {
        let payload = Data("""
        {
            "stationuuid": "flexible",
            "name": "Flexible",
            "url": "https://example.com/stream",
            "country": "United States",
            "votes": 1,
            "lastcheckok": \(value)
        }
        """.utf8)

        return try DefaultJSONDecoder().decode(StationObject.self, from: payload)
    }
}
