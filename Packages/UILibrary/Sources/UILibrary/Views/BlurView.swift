import SwiftUI

public struct BlurView: View {
    public enum Style {
        case ultraThin
        case thin
        case regular
        case thick
        case ultraThick
    }

    private let blurStyle: Style

    public init(blurStyle: Style = .regular) {
        self.blurStyle = blurStyle
    }

    public var body: some View {
        Rectangle()
            .fill(material)
    }

    private var material: Material {
        switch blurStyle {
        case .ultraThin:
            return .ultraThinMaterial
        case .thin:
            return .thinMaterial
        case .regular:
            return .regularMaterial
        case .thick:
            return .thickMaterial
        case .ultraThick:
            return .ultraThickMaterial
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        VStack(spacing: 24) {
            BlurView(blurStyle: .ultraThin)
                .frame(height: 80)

            BlurView(blurStyle: .thin)
                .frame(height: 80)

            BlurView(blurStyle: .regular)
                .frame(height: 80)

            BlurView(blurStyle: .thick)
                .frame(height: 80)

            BlurView(blurStyle: .ultraThick)
                .frame(height: 80)
        }
        .padding()
        .backgroundStyle(.clear)
    }
    .background(SeaSurfGradientView())
}
#endif
