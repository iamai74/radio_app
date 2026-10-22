import SwiftUI

public enum AppImage {
    case favoriteUnfilled
    case favoriteFilled
    case search
    case heart
    case play
    case pause
    case volumeMuted
    case volumeLow
    case volumeMedium
    case volumeHigh
    case gauge
    case globe
    case radio

    public var name: String {
        switch self {
        case .favoriteUnfilled: "star"
        case .favoriteFilled: "star.fill"
        case .search: "magnifyingglass"
        case .heart: "heart.fill"
        case .play: "play.fill"
        case .pause: "pause.fill"
        case .volumeMuted: "speaker.slash"
        case .volumeLow: "speaker.wave.1"
        case .volumeMedium: "speaker.wave.2"
        case .volumeHigh: "speaker.wave.3"
        case .gauge: "gauge.medium"
        case .globe: "globe"
        case .radio: "radio"
        }
    }

    public var view: Image {
        Image(systemName: name)
    }
}
