import SwiftUI

public final class GradientViewModel: ObservableObject {
    @Published var colors: [Color]

    private let colorCount: Int
    private let interval: Double

    private var timer: Timer?

    public init(colorCount: Int = 4, interval: Double = 3.0) {
        self.colorCount = max(colorCount, 2)
        self.interval = interval
        self.colors = Self.randomColors(count: self.colorCount)
        startAnimating()
    }

    deinit {
        stopAnimating()
    }

    public func randomize() {
        colors = Self.randomColors(count: colorCount)
    }

    private func startAnimating() {
        stopAnimating()
        let vmPtr = Unmanaged.passUnretained(self).toOpaque()
        timer = .scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            let strong = Unmanaged<GradientViewModel>.fromOpaque(vmPtr).takeUnretainedValue()
            strong.colors = Self.randomColors(count: strong.colorCount)
        }
    }

    private func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }

    private static func randomColors(count: Int) -> [Color] {
        (0..<count).map { _ in
            Color(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1)
            )
        }
    }
}

public struct GradientView: View {
    public enum Style {
        case linear
        case radial
        case angular
    }

    @StateObject private var viewModel: GradientViewModel

    private let gradientStyle: Style

    public init(
        gradientStyle: Style = .linear,
        colorCount: Int = 4,
        animationDuration: Double = 3.0
    ) {
        self.gradientStyle = gradientStyle
        _viewModel = StateObject(wrappedValue: GradientViewModel(
            colorCount: colorCount,
            interval: animationDuration
        ))
    }

    public var body: some View {
        Rectangle()
            .fill(makeGradient(colors: viewModel.colors))
            .animation(.easeInOut(duration: 0.8), value: viewModel.colors)
    }

    private func makeGradient(colors: [Color]) -> AnyShapeStyle {
        switch gradientStyle {
        case .linear:
            return AnyShapeStyle(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .radial:
            return AnyShapeStyle(
                RadialGradient(
                    colors: colors,
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
            )
        case .angular:
            return AnyShapeStyle(
                AngularGradient(
                    colors: colors,
                    center: .center
                )
            )
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 24) {
        GradientView(gradientStyle: .linear)
            .frame(height: 200)

        GradientView(gradientStyle: .radial)
            .frame(height: 200)

        GradientView(gradientStyle: .angular)
            .frame(height: 200)
    }
    .padding()
}
#endif
