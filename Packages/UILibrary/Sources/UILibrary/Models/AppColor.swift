import SwiftUI

public enum AppColor {
    case seaSurfGradientDeep
    case seaSurfGradientMid
    case seaSurfGradientShallow
    case seaSurfWaveSurface
    case seaSurfWaveMid
    case seaSurfWaveDeep
    case seaSurfWaveBottom
    case seaWaveGentle1
    case seaWaveGentle2
    case seaWaveGentle3
    case seaWaveModerate1
    case seaWaveModerate2
    case seaWaveModerate3
    case seaWaveIntense1
    case seaWaveIntense2
    case seaWaveIntense3
    case seaWaveIntense4
    case customDarkNavy
    case emptyLayerBackground

    public var color: Color {
        switch self {
        case .seaSurfGradientDeep:
            Color(red: 0.01, green: 0.06, blue: 0.16)
        case .seaSurfGradientMid:
            Color(red: 0.02, green: 0.22, blue: 0.36)
        case .seaSurfGradientShallow:
            Color(red: 0.04, green: 0.45, blue: 0.52)
        case .seaSurfWaveSurface:
            Color(red: 0.20, green: 0.75, blue: 0.78)
        case .seaSurfWaveMid:
            Color(red: 0.05, green: 0.55, blue: 0.65)
        case .seaSurfWaveDeep:
            Color(red: 0.03, green: 0.35, blue: 0.55)
        case .seaSurfWaveBottom:
            Color(red: 0.02, green: 0.15, blue: 0.35)
        case .seaWaveGentle1:
            .blue.opacity(0.6)
        case .seaWaveGentle2:
            .cyan.opacity(0.4)
        case .seaWaveGentle3:
            .blue.opacity(0.8)
        case .seaWaveModerate1:
            .blue.opacity(0.7)
        case .seaWaveModerate2:
            .cyan.opacity(0.5)
        case .seaWaveModerate3:
            .purple.opacity(0.6)
        case .seaWaveIntense1:
            .blue
        case .seaWaveIntense2:
            .cyan
        case .seaWaveIntense3:
            .purple
        case .seaWaveIntense4:
            .blue.opacity(0.7)
        case .customDarkNavy:
            Color(red: 0.05, green: 0.08, blue: 0.25)
        case .emptyLayerBackground:
            .accentColor.opacity(0.1)
        }
    }
}
