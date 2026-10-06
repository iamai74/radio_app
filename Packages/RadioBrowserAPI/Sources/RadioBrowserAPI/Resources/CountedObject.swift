import Foundation

/// The payload of the counted resource routes.
///
/// The service answers `/json/languages`, `/json/tags` and `/json/codecs` with the same
/// two fields, so one type decodes all three (countries differ by their ISO code and keep
/// their own payload in ``CountryObject``).
///
/// The type conforms to the three kind protocols — ``StationTag``, ``Language``,
/// ``Codec`` — so an endpoint can hand it back as its resource; which kind a value *is*
/// stays decided by the route it was fetched from (`api.tags` vs `api.languages`), not by
/// a cast on the value.
package struct CountedObject: Codable, StationTag, Language, Codec {
    package let name: String
    package let stationCount: Int

    /// - Parameters:
    ///   - name: The name of the resource, as the service reports it.
    ///   - stationCount: The number of stations it accounts for.
    package init(name: String, stationCount: Int) {
        self.name = name
        self.stationCount = stationCount
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case stationCount = "stationcount"
    }
}
