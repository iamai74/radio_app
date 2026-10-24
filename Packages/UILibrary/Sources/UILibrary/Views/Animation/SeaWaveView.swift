import SwiftUI

public struct SeaWaveView: View {
    public enum WaveConfig {
        case gentle(
            colors: [Color] = [AppColor.seaWaveGentle1.color, AppColor.seaWaveGentle2.color, AppColor.seaWaveGentle3.color],
            amplitude: CGFloat = 20,
            waveCount: Int = 3,
            speed: Double = 0.03
        )
        case moderate(
            colors: [Color] = [AppColor.seaWaveModerate1.color, AppColor.seaWaveModerate2.color, AppColor.seaWaveModerate3.color],
            amplitude: CGFloat = 35,
            waveCount: Int = 4,
            speed: Double = 0.05
        )
        case intense(
            colors: [Color] = [AppColor.seaWaveIntense1.color, AppColor.seaWaveIntense2.color, AppColor.seaWaveIntense3.color, AppColor.seaWaveIntense4.color],
            amplitude: CGFloat = 50,
            waveCount: Int = 5,
            speed: Double = 0.08
        )
        case custom(
            colors: [Color],
            amplitude: CGFloat,
            waveCount: Int,
            speed: Double
        )
    }

    private let waveColors: [Color]
    private let waveAmplitude: CGFloat
    private let waveCount: Int
    private let baseSpeed: Double

    public init(waveConfig: WaveConfig = .moderate()) {
        switch waveConfig {
        case .gentle(colors: let colors, amplitude: let amp, waveCount: let count, speed: let speed):
            self.waveColors = colors
            self.waveAmplitude = amp
            self.waveCount = count
            self.baseSpeed = speed
        case .moderate(colors: let colors, amplitude: let amp, waveCount: let count, speed: let speed):
            self.waveColors = colors
            self.waveAmplitude = amp
            self.waveCount = count
            self.baseSpeed = speed
        case .intense(colors: let colors, amplitude: let amp, waveCount: let count, speed: let speed):
            self.waveColors = colors
            self.waveAmplitude = amp
            self.waveCount = count
            self.baseSpeed = speed
        case .custom(colors: let colors, amplitude: let amp, waveCount: let count, speed: let speed):
            self.waveColors = colors
            self.waveAmplitude = amp
            self.waveCount = count
            self.baseSpeed = speed
        }
    }

    public var body: some View {
        TimelineView(.animation) { proxy in
            ZStack {
                ForEach(0..<waveCount, id: \.self) { index in
                    let layerSpeed = baseSpeed * (1 + Double(index) * 0.3)
                    let phase = Double(proxy.date.timeIntervalSinceReferenceDate) * layerSpeed
                    let adjustedAmplitude = waveAmplitude * (1 - CGFloat(index) * 0.15)

                    WaveShape(
                        phase: phase,
                        amplitude: adjustedAmplitude,
                        cycles: 2 + CGFloat(index)
                    )
                    .fill(waveColors[index % waveColors.count])
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct WaveShape: Shape {
    private var phase: Double
    private let amplitude: CGFloat
    private let cycles: CGFloat

    init(phase: Double, amplitude: CGFloat, cycles: CGFloat) {
        self.phase = phase
        self.amplitude = amplitude
        self.cycles = cycles
    }

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let scaledAmplitude = amplitude * (rect.height / rect.width)
        var path = Path()
        let pointCount = 100
        let step = rect.width / CGFloat(pointCount)

        path.move(to: CGPoint(x: 0, y: rect.height))

        for pointIndex in 0...pointCount {
            let pointX = CGFloat(pointIndex) * step
            let progress = Double(pointIndex) / Double(pointCount)
            let wave = sin(progress * .pi * 2 * cycles + phase * .pi * 2)
            let pointY = rect.height * 0.5 + wave * scaledAmplitude
            path.addLine(to: CGPoint(x: pointX, y: pointY))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 40) {
        SeaWaveView(waveConfig: .gentle())
            .frame(height: 200)
            .background(Color.black)

        SeaWaveView(waveConfig: .moderate())
            .frame(height: 200)
            .background(Color.black)

        SeaWaveView(waveConfig: .intense())
            .frame(height: 200)
            .background(Color.black)
    }
    .padding()
}
#endif
