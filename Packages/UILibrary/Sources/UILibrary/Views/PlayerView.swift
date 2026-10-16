import SwiftUI

public struct PlayerView: View {
    let station: any Station
    let isPlaying: Bool
    let volume: Double
    let onPlayPause: () -> Void
    let onVolumeChange: (Double) -> Void
    let onFavoriteToggle: () -> Void

    public init(
        station: some Station,
        isPlaying: Bool = false,
        volume: Double = 0.5,
        onPlayPause: @escaping () -> Void = {},
        onVolumeChange: @escaping (Double) -> Void = { _ in },
        onFavoriteToggle: @escaping () -> Void = {}
    ) {
        self.station = station
        self.isPlaying = isPlaying
        self.volume = volume
        self.onPlayPause = onPlayPause
        self.onVolumeChange = onVolumeChange
        self.onFavoriteToggle = onFavoriteToggle
    }

    public var body: some View {
        PlayerContentView(
            station: station,
            isPlaying: isPlaying,
            volume: volume,
            onPlayPause: onPlayPause,
            onVolumeChange: onVolumeChange,
            onFavoriteToggle: onFavoriteToggle
        )
    }
}

private struct PlayerContentView: View {
    @State private var currentVolume: Double

    let station: any Station
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onVolumeChange: (Double) -> Void
    let onFavoriteToggle: () -> Void

    init(
        station: any Station,
        isPlaying: Bool,
        volume: Double,
        onPlayPause: @escaping () -> Void,
        onVolumeChange: @escaping (Double) -> Void,
        onFavoriteToggle: @escaping () -> Void
    ) {
        self.station = station
        self.isPlaying = isPlaying
        self._currentVolume = State(initialValue: volume)
        self.onPlayPause = onPlayPause
        self.onVolumeChange = onVolumeChange
        self.onFavoriteToggle = onFavoriteToggle
    }

    var body: some View {
        VStack(spacing: 16) {
            artworkView

            infoView

            volumeView

            controlsView
        }
        .padding(.horizontal)
        .padding(.vertical, 24)
    }

    private var artworkView: some View {
        AsyncImage(url: URL(string: station.favicon ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                placeholderImage
            @unknown default:
                placeholderImage
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }

    private var placeholderImage: some View {
        Image(systemName: "radio.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(.secondary)
    }

    private var infoView: some View {
        VStack(spacing: 8) {
            TextView(station.name, size: .h3)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if let tags = station.tags, !tags.isEmpty {
                TagsCloudView(
                    tags: Array(tags.prefix(4)),
                    spacing: 6,
                    horizontalPadding: 0
                )
            }

            HStack(spacing: 8) {
                if let bitrate = station.bitrate, bitrate > 0 {
                    Label(
                        "\(bitrate) kbps",
                        systemImage: "gauge.medium"
                    )
                    .labelStyle(.titleAndIcon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                if !station.country.isEmpty {
                    Label(
                        station.country,
                        systemImage: "globe"
                    )
                    .labelStyle(.titleAndIcon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var volumeView: some View {
        HStack(spacing: 12) {
            Image(systemName: volumeIcon(for: currentVolume))
                .foregroundStyle(.secondary)
                .font(.caption)

            Slider(
                value: $currentVolume,
                in: 0...1,
                onEditingChanged: { _ in onVolumeChange(currentVolume) }
            )
            .tint(.accentColor)

            TextView("\(Int(currentVolume * 100))%", size: .caption, textStyle: .secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private var controlsView: some View {
        HStack(spacing: 32) {
            Button(action: onFavoriteToggle) {
                Image(systemName: station.isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(station.isFavorite ? .red : .secondary)
            }
            .buttonStyle(.plain)

            Button(action: onPlayPause) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 60, height: 60)

                    Image(systemName: playPauseIcon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .scaleEffect(isPlaying ? 1.1 : 1)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private var playPauseIcon: String {
        isPlaying ? "pause.fill" : "play.fill"
    }

    private func volumeIcon(for volume: Double) -> String {
        if volume == 0 {
            return "speaker.slash"
        } else if volume < 0.3 {
            return "speaker.wave.1"
        } else if volume < 0.7 {
            return "speaker.wave.2"
        } else {
            return "speaker.wave.3"
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()

        PlayerView(
            station: MockStations.jazzRadio,
            isPlaying: true,
            volume: 0.65
        )
    }
}
