import SwiftUI

public struct StationRowView: View {
    let station: any Station
    @State private var loadedImage: Image?
    @State private var isLoadingImage = true

    public init(station: any Station) {
        self.station = station
    }

    public var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                image: loadedImage ?? AppImage.radio.view,
                initials: String(station.name.prefix(2)),
                size: .s,
                isLoading: isLoadingImage
            )
            .task {
                await loadImage()
            }

            VStack(alignment: .leading, spacing: 4) {
                TextView(station.name, size: .h4)
                    .lineLimit(1)

                TextView(station.country, size: .subheadline, textStyle: .secondary)
                    .lineLimit(1)

                                  if let tags = station.tags, !tags.isEmpty {
                                      TagsCloudView(
                                          tags: Array(tags.prefix(3)),
                                          spacing: 4,
                                          horizontalPadding: 0
                                      )
                                  }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let bitrate = station.bitrate, bitrate > 0 {
                    TextView("\(bitrate) kbps", size: .caption, textStyle: .secondary)
                }

                if station.isFavorite {
                    AppImage.favoriteFilled.view
                        .foregroundStyle(AppColor.favorite.color)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
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
    List {
        StationRowView(station: MockStations.jazzRadio)
        StationRowView(station: MockStations.classical)
        StationRowView(station: MockStations.rockRadio)
    }
    .listStyle(.plain)
}
