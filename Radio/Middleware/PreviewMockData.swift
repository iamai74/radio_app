import Foundation
import UILibrary

struct MockStation: Station {
    let id: String
    let name: String
    let url: String
    let homepage: String?
    let favicon: String?
    let tags: [String]?
    let country: String
    let state: String?
    let language: String?
    let votes: Int
    let bitrate: Int?
    let lastCheckOk: Bool
    let isFavorite: Bool

    init(
        id: String,
        name: String,
        url: String,
        homepage: String? = nil,
        favicon: String? = nil,
        tags: [String]? = nil,
        country: String,
        state: String? = nil,
        language: String? = nil,
        votes: Int = 0,
        bitrate: Int? = nil,
        lastCheckOk: Bool = true,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.homepage = homepage
        self.favicon = favicon
        self.tags = tags
        self.country = country
        self.state = state
        self.language = language
        self.votes = votes
        self.bitrate = bitrate
        self.lastCheckOk = lastCheckOk
        self.isFavorite = isFavorite
    }
}

enum MockStations {
    static let jazzRadio = MockStation(
        id: "1",
        name: "Jazz Radio",
        url: "https://jazz.streamr.fm",
        homepage: "https://www.jazzradio.com",
        favicon: "https://www.google.com/s2/favicons?domain=www.jazzradio.com&sz=128",
        tags: ["jazz", "smooth jazz", "instrumental"],
        country: "United States",
        state: "California",
        language: "English",
        votes: 1500,
        bitrate: 128,
        lastCheckOk: true,
        isFavorite: true
    )

    static let classical = MockStation(
        id: "2",
        name: "Classical FM",
        url: "https://classical.streamr.fm",
        homepage: "https://www.classicalfm.co.uk",
        favicon: "https://www.google.com/s2/favicons?domain=www.classicalfm.co.uk&sz=128",
        tags: ["classical", "orchestra", "symphony"],
        country: "United Kingdom",
        state: "England",
        language: "English",
        votes: 2300,
        bitrate: 256,
        lastCheckOk: true,
        isFavorite: false
    )

    static let rockRadio = MockStation(
        id: "3",
        name: "Rock Radio",
        url: "https://rock.streamr.fm",
        homepage: "https://www.rockradio.com",
        favicon: "https://www.google.com/s2/favicons?domain=www.rockradio.com&sz=128",
        tags: ["rock", "classic rock", "metal"],
        country: "Germany",
        state: nil,
        language: "German",
        votes: 3100,
        bitrate: 192,
        lastCheckOk: false,
        isFavorite: true
    )

    static let all: [any Station] = [jazzRadio, classical, rockRadio]
}
