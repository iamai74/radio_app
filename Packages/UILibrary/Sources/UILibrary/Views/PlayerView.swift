import SwiftUI

public enum PlayerLayout: String, CaseIterable {
    case vertical
    case horizontal
}

public struct PlayerView: View {
    let station: any Station
    let isPlaying: Bool
    let volume: Double
    let layout: PlayerLayout
    let onPlayPause: () -> Void
    let onVolumeChange: (Double) -> Void
    let onFavoriteToggle: () -> Void

    public init(
        station: some Station,
        isPlaying: Bool = false,
        volume: Double = 0.5,
        layout: PlayerLayout = .vertical,
        onPlayPause: @escaping () -> Void = {},
        onVolumeChange: @escaping (Double) -> Void = { _ in },
        onFavoriteToggle: @escaping () -> Void = {}
    ) {
        self.station = station
        self.isPlaying = isPlaying
        self.volume = volume
        self.layout = layout
        self.onPlayPause = onPlayPause
        self.onVolumeChange = onVolumeChange
        self.onFavoriteToggle = onFavoriteToggle
    }

    public var body: some View {
        PlayerContentView(
            station: station,
            isPlaying: isPlaying,
            volume: volume,
            layout: layout,
            onPlayPause: onPlayPause,
            onVolumeChange: onVolumeChange,
            onFavoriteToggle: onFavoriteToggle
        )
    }
}

private struct PlayerContentView: View {
    @State private var currentVolume: Double
    @State private var loadedImage: Image?
    @State private var isLoadingImage = true

    let station: any Station
    let isPlaying: Bool
    let layout: PlayerLayout
    let onPlayPause: () -> Void
    let onVolumeChange: (Double) -> Void
    let onFavoriteToggle: () -> Void

    init(
        station: any Station,
        isPlaying: Bool,
        volume: Double,
        layout: PlayerLayout,
        onPlayPause: @escaping () -> Void,
        onVolumeChange: @escaping (Double) -> Void,
        onFavoriteToggle: @escaping () -> Void
    ) {
        self.station = station
        self.isPlaying = isPlaying
        self.layout = layout
        self._currentVolume = State(initialValue: volume)
        self.onPlayPause = onPlayPause
        self.onVolumeChange = onVolumeChange
        self.onFavoriteToggle = onFavoriteToggle
    }

    var body: some View {
        switch layout {
        case .vertical:
            verticalBody
        case .horizontal:
            horizontalBody
        }
    }

    private var verticalBody: some View {
        ZStack {
            VStack(spacing: 16) {
                artworkView(size: .xxl)

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
                        .frame(maxWidth: .infinity)
                    }

                    metadataLabels
                }

                volumeView

                playPauseButton
            }
            .padding(.horizontal)
            .padding(.vertical, 24)

            VStack {
                HStack {
                    Spacer()
                    favoriteButton
                }

                Spacer()
            }
        }
    }

    private var horizontalBody: some View {
        HStack(spacing: 16) {
            artworkView(size: .xl)

            VStack(alignment: .leading, spacing: 12) {
                infoView(alignment: .leading)

                volumeView
            }

            Spacer()

            playPauseButton
        }
        .padding()
    }

    private func artworkView(size: AvatarView.Size) -> some View {
        AvatarView(
            image: loadedImage,
            initials: String(station.name.prefix(2)),
            size: size,
            isLoading: isLoadingImage
        )
        .task {
            await loadImage()
        }
        .shadow(radius: 4)
    }

    private func infoView(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 8) {
            TextView(station.name, size: .h3)
                .lineLimit(2)
                .multilineTextAlignment(alignment == .leading ? .leading : .center)

            if let tags = station.tags, !tags.isEmpty {
                TagsCloudView(
                    tags: Array(tags.prefix(4)),
                    spacing: 6,
                    horizontalPadding: 0
                )
            }

            metadataLabels
        }
    }

    private var metadataLabels: some View {
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

    private var favoriteButton: some View {
        Button(action: onFavoriteToggle) {
            Image(systemName: station.isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(station.isFavorite ? .red : .secondary)
        }
        .buttonStyle(.plain)
    }

    private var playPauseButton: some View {
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

    @MainActor
    private func loadImage() async {
        guard isLoadingImage else { return }
        guard let favicon = station.favicon,
              let url = URL(string: favicon) else {
            isLoadingImage = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
#if os(iOS)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
#elseif os(macOS)
            if let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
#endif
        } catch {
            // Ignore loading errors
        }
        isLoadingImage = false
    }
}

#Preview {
    NavigationStack {
        Form {
            Section("Vertical Layout") {
                PlayerView(
                    station: MockStations.jazzRadio,
                    isPlaying: true,
                    volume: 0.65,
                    layout: .vertical
                )
            }

            Section("Horizontal Layout") {
                PlayerView(
                    station: MockStations.jazzRadio,
                    isPlaying: true,
                    volume: 0.65,
                    layout: .horizontal
                )
            }
        }
    }
}
