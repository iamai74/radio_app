import SwiftUI

public struct AudioVisualizerView: View {
    public enum Style {
        case columns
        case wave
    }

    private let bands: [Double]
    private let style: Style
    private let primaryColor: Color
    private let secondaryColor: Color
    private let lineWidth: CGFloat

    public init(
        bands: AudioFrequencyBands,
        style: Style = .columns,
        primaryColor: Color = .accentColor,
        secondaryColor: Color? = nil,
        lineWidth: CGFloat = 3
    ) {
        self.bands = bands.bands
        self.style = style
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor ?? primaryColor.opacity(0.4)
        self.lineWidth = lineWidth
    }

    public var body: some View {
        switch style {
        case .columns:
            columnsView
        case .wave:
            waveView
        }
    }

    private var emptyLayer: some View {
        Rectangle()
            .fill(primaryColor.opacity(0.1))
    }

    private var columnsView: some View {
        Group {
            if bands.isEmpty {
                emptyLayer
            } else {
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        ForEach(0..<bands.count, id: \.self) { index in
                            let bandValue = bands[index]
                            let columnWidth = max(1, geometry.size.width / CGFloat(bands.count) - 2)
                            let height = max(2, bandValue * geometry.size.height)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [secondaryColor, primaryColor],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: columnWidth, height: height)
                                .position(
                                    x: CGFloat(index) * (geometry.size.width / CGFloat(bands.count))
                                        + (geometry.size.width / CGFloat(bands.count)) / 2,
                                    y: geometry.size.height / 2 + (geometry.size.height / 2 - height / 2)
                                )
                        }
                    }
                }
            }
        }
    }

    private var waveView: some View {
        Group {
            if bands.isEmpty {
                emptyLayer
            } else {
                GeometryReader { geometry in
                    let rect = CGRect(origin: .zero, size: geometry.size)

                    ZStack {
                        createFilledPath(rect: rect)
                            .fill(
                                LinearGradient(
                                    colors: [primaryColor.opacity(0.3), primaryColor.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        createOutlinePath(rect: rect)
                            .stroke(
                                LinearGradient(
                                    colors: [secondaryColor, primaryColor, secondaryColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(
                                    lineWidth: lineWidth,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                    }
                }
            }
        }
    }

    private func createOutlinePath(rect: CGRect) -> Path {
        var path = Path()
        guard !bands.isEmpty else { return path }

        let centerY = rect.midY
        let step = rect.width / CGFloat(bands.count)

        for (index, band) in bands.enumerated() {
            let pointX = CGFloat(index) * step
            let pointY = centerY - (band * rect.height * 0.4)

            if index == 0 {
                path.move(to: CGPoint(x: 0, y: pointY))
            } else {
                let prevPointX = step * CGFloat(index - 1)
                let prevBand = bands[index - 1]
                let prevPointY = centerY - (prevBand * rect.height * 0.4)
                let controlX = (prevPointX + pointX) / 2
                path.addCurve(
                    to: CGPoint(x: pointX, y: pointY),
                    control1: CGPoint(x: controlX, y: prevPointY),
                    control2: CGPoint(x: controlX, y: pointY)
                )
            }
        }

        return path
    }

    private func createFilledPath(rect: CGRect) -> Path {
        var path = Path()
        guard !bands.isEmpty else { return path }

        let centerY = rect.midY
        let step = rect.width / CGFloat(bands.count)

        for (index, band) in bands.enumerated() {
            let pointX = CGFloat(index) * step
            let pointY = centerY - (band * rect.height * 0.4)

            if index == 0 {
                path.move(to: CGPoint(x: 0, y: pointY))
            } else {
                let prevPointX = step * CGFloat(index - 1)
                let prevBand = bands[index - 1]
                let prevPointY = centerY - (prevBand * rect.height * 0.4)
                let controlX = (prevPointX + pointX) / 2
                path.addCurve(
                    to: CGPoint(x: pointX, y: pointY),
                    control1: CGPoint(x: controlX, y: prevPointY),
                    control2: CGPoint(x: controlX, y: pointY)
                )
            }
        }

        let lastPointX = step * CGFloat(bands.count - 1)
        path.addLine(to: CGPoint(x: lastPointX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

#if DEBUG
#Preview("Columns Style") {
    ZStack {
        Color.black
            .ignoresSafeArea()

        AudioVisualizerView(
            bands: AudioFrequencyBands.random(count: 32),
            style: .columns,
            primaryColor: .accentColor,
            secondaryColor: .blue.opacity(0.4),
            lineWidth: 3
        )
        .frame(height: 120)
        .frame(maxWidth: 400)
        .cornerRadius(12)
    }
}

#Preview("Wave Style") {
    ZStack {
        Color.black
            .ignoresSafeArea()

        AudioVisualizerView(
            bands: AudioFrequencyBands.random(count: 32),
            style: .wave,
            primaryColor: .purple,
            secondaryColor: .cyan.opacity(0.4),
            lineWidth: 2
        )
        .frame(height: 120)
        .frame(maxWidth: 400)
        .cornerRadius(12)
    }
}

#Preview("Empty Bands") {
    ZStack {
        Color.black
            .ignoresSafeArea()

        AudioVisualizerView(
            bands: .empty(),
            style: .columns,
            primaryColor: .gray,
            lineWidth: 3
        )
        .frame(height: 120)
        .frame(maxWidth: 400)
        .cornerRadius(12)
    }
}
#endif
