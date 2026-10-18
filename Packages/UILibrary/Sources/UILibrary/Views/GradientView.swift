import SwiftUI

@MainActor
public final class GradientAnimator: ObservableObject {
    @Published var colors: [Color]
    @Published var startPoint: UnitPoint
    @Published var endPoint: UnitPoint

    private let colorCount: Int
    private let colorInterval: UInt64
    private let pointInterval: UInt64
    private var colorTask: Task<Void, Never>?
    private var pointTask: Task<Void, Never>?

    private let gradientPoints: [(UnitPoint, UnitPoint)] = [
        (.leading, .trailing),
        (.topLeading, .bottomTrailing),
        (.top, .bottom),
        (.topTrailing, .bottomLeading)
    ]

    private var pointIndex = 0

    public init(
        colorCount: Int = 4,
        colorInterval: TimeInterval = 4.0,
        pointInterval: TimeInterval = 6.0
    ) {
        self.colorCount = max(colorCount, 2)
        self.colorInterval = UInt64(colorInterval * 1_000_000_000)
        self.pointInterval = UInt64(pointInterval * 1_000_000_000)
        self.colors = Self.randomColors(count: self.colorCount)
        self.startPoint = gradientPoints[0].0
        self.endPoint = gradientPoints[0].1
        startAnimating()
    }

    public func randomize() {
        colors = Self.randomColors(count: colorCount)
    }

    private func startAnimating() {
        cancelAnimating()
        colorTask = Task { [weak self] in
            await self?.animateColors()
        }
        pointTask = Task { [weak self] in
            await self?.animatePoints()
        }
    }

    private func cancelAnimating() {
        colorTask?.cancel()
        colorTask = nil
        pointTask?.cancel()
        pointTask = nil
    }

    private func animateColors() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: colorInterval)
            withAnimation(.easeInOut(duration: 2.5)) {
                colors = Self.randomColors(count: colorCount)
            }
        }
    }

    private func animatePoints() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: pointInterval)
            pointIndex = (pointIndex + 1) % gradientPoints.count
            let pair = gradientPoints[pointIndex]
            withAnimation(.easeInOut(duration: 3.0)) {
                startPoint = pair.0
                endPoint = pair.1
            }
        }
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

    @StateObject private var animator: GradientAnimator

    private let gradientStyle: Style

    public init(
        gradientStyle: Style = .linear,
        colorCount: Int = 4,
        animationDuration: Double = 4.0
    ) {
        self.gradientStyle = gradientStyle
        _animator = StateObject(wrappedValue: GradientAnimator(
            colorCount: colorCount,
            colorInterval: animationDuration
        ))
    }

    public var body: some View {
        Rectangle()
            .fill(makeGradient(
                colors: animator.colors,
                startPoint: animator.startPoint,
                endPoint: animator.endPoint
            ))
    }

    private func makeGradient(
        colors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> AnyShapeStyle {
        switch gradientStyle {
        case .linear:
            return AnyShapeStyle(
                LinearGradient(
                    colors: colors,
                    startPoint: startPoint,
                    endPoint: endPoint
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
