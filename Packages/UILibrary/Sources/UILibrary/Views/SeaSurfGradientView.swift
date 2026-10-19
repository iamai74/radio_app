import SwiftUI

public struct SeaSurfGradientView: View {
    public struct Configuration {
        public var gradientColors: [Color]
        public var waveColors: [Color]
        public var foamColor: Color
        public var amplitude: CGFloat
        public var waveCount: Int
        public var speed: Double

        public init(
            gradientColors: [Color] = [
                Color(red: 0.01, green: 0.06, blue: 0.16),
                Color(red: 0.02, green: 0.22, blue: 0.36),
                Color(red: 0.04, green: 0.45, blue: 0.52)
            ],
            waveColors: [Color] = [
                Color(red: 0.20, green: 0.75, blue: 0.78),
                Color(red: 0.05, green: 0.55, blue: 0.65),
                Color(red: 0.03, green: 0.35, blue: 0.55),
                Color(red: 0.02, green: 0.15, blue: 0.35)
            ],
            foamColor: Color = .white.opacity(0.8),
            amplitude: CGFloat = 24,
            waveCount: Int = 4,
            speed: Double = 0.4
        ) {
            self.gradientColors = gradientColors
            self.waveColors = waveColors
            self.foamColor = foamColor
            self.amplitude = amplitude
            self.waveCount = max(waveCount, 1)
            self.speed = speed
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            GeometryReader { geometry in
                ZStack {
                    oceanGradient(time: time)
                    ForEach(0..<configuration.waveCount, id: \.self) { index in
                        waveLayer(index: index, time: time, size: geometry.size)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }

    private func oceanGradient(time: TimeInterval) -> some View {
        let drift = sin(time * configuration.speed * 0.5)
        return LinearGradient(
            colors: configuration.gradientColors,
            startPoint: UnitPoint(x: 0.5 + drift * 0.15, y: 0),
            endPoint: UnitPoint(x: 0.5 - drift * 0.15, y: 1)
        )
        .hueRotation(.degrees(sin(time * 0.1) * 20))
    }

    private func waveLayer(index: Int, time: TimeInterval, size: CGSize) -> some View {
        let progress = configuration.waveCount > 1
            ? Double(index) / Double(configuration.waveCount - 1)
            : 0
        let layerSpeed = configuration.speed * (1 + progress * 0.6)
        let layerAmplitude = configuration.amplitude * (1 - progress * 0.35)
        let baseline = 0.45 + progress * 0.3
        let layerColor = configuration.waveColors[index % configuration.waveColors.count]
        let shape = SurfWaveShape(
            phase: time * layerSpeed,
            amplitude: layerAmplitude,
            baseline: baseline
        )

        return ZStack {
            shape
                .fill(configuration.foamColor.opacity(0.35 * (1 - progress)))
                .offset(y: -3)
                .blur(radius: 4)
            shape.fill(layerColor)
        }
    }
}

private struct SurfWaveShape: Shape {
    private var phase: Double
    private let amplitude: CGFloat
    private let baseline: Double

    init(phase: Double, amplitude: CGFloat, baseline: Double) {
        self.phase = phase
        self.amplitude = amplitude
        self.baseline = baseline
    }

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let baselineY = rect.height * baseline
        let pointCount = 100
        let step = rect.width / CGFloat(pointCount)
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.height))

        for pointIndex in 0...pointCount {
            let pointX = CGFloat(pointIndex) * step
            let progress = Double(pointIndex) / Double(pointCount)
            let wave = sin(progress * .pi * 4 + phase * .pi * 2)
            let pointY = baselineY + wave * amplitude
            path.addLine(to: CGPoint(x: pointX, y: pointY))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}

#if DEBUG
#Preview("Sea Surf Gradient") {
    SeaSurfGradientView()
        .frame(height: 320)
}

#Preview("Custom Configuration") {
    SeaSurfGradientView(
        configuration: .init(
            gradientColors: [.black.opacity(0.7), .indigo, .cyan.opacity(0.6)],
            waveColors: [.mint, .teal, .blue, Color(red: 0.05, green: 0.08, blue: 0.25)],
            amplitude: 40,
            waveCount: 5,
            speed: 0.8
        )
    )
    .frame(height: 320)
}
#endif
