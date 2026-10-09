import SwiftUI

public struct LoadingIndicator: View {
    public enum Size {
        case small
        case medium
        case large
    }

    public var isLoading: Bool
    let size: Size

    public init(isLoading: Bool, size: Size = .medium) {
        self.isLoading = isLoading
        self.size = size
    }

    public var body: some View {
        Group {
            if isLoading {
                TimelineView(.animation) { timeline in
                    ZStack {
                        ForEach(0..<8) { item in
                            Circle()
                                .fill(Color.primary)
                                .frame(width: dotSize, height: dotSize)
                                .offset(x: radius * sin(angle(for: item)),
                                        y: -radius * cos(angle(for: item)))
                                .opacity(dotOpacity(for: item, date: timeline.date))
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    private var dotSize: CGFloat {
        size.dotDiameter
    }

    private var radius: CGFloat {
        size.radius
    }

    private func angle(for index: Int) -> CGFloat {
        CGFloat(index) * (2 * .pi / 8)
    }

    private func dotOpacity(for index: Int, date: Date) -> Double {
        let time = date.timeIntervalSinceReferenceDate
        let period: Double = 1.0
        let offset = Double(index) * (period / 8.0)
        let progress = (time - offset).truncatingRemainder(dividingBy: period)
        let normalizedProgress = (progress + period).truncatingRemainder(dividingBy: period) / period
        return 1.0 - abs(2.0 * (normalizedProgress - 0.5))
    }
}

extension LoadingIndicator.Size {
    var radius: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 15
        case .large: return 20
        }
    }

    var dotDiameter: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

#if DEBUG
struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LoadingIndicator(isLoading: true, size: .small)
            LoadingIndicator(isLoading: true, size: .medium)
            LoadingIndicator(isLoading: true, size: .large)
            LoadingIndicator(isLoading: false, size: .medium)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
