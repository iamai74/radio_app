import SwiftUI

public enum StationRowLayout: String, CaseIterable {
    case horizontal
    case vertical
}

public struct StationRowView: View {
    @Binding var layout: StationRowLayout
    let station: any Station
    @State private var stationImage: Image?
    @State private var isImageLoading: Bool

    public init(
        layout: Binding<StationRowLayout> = .constant(.horizontal),
        station: any Station,
        stationImage: Image? = nil,
        isImageLoading: Bool = false
    ) {
        self._layout = layout
        self.station = station
        self._stationImage = State(initialValue: stationImage)
        self._isImageLoading = State(initialValue: isImageLoading)
    }

    public func updateImage(image: Image?) {
        self.stationImage = image
        self.isImageLoading = false
    }

    public func startImageLoading() {
        self.isImageLoading = true
    }

    public var body: some View {
        switch layout {
        case .horizontal:
            horizontalBody
        case .vertical:
            verticalBody
        }
    }

    private var horizontalBody: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 12) {
                avatarView

                VStack(alignment: .leading, spacing: 4) {
                    StationNameTextView(name: station.name, size: .h4)
                        .lineLimit(1)

                    CountryLabelView(country: station.country)
                        .lineLimit(1)

                    if let bitrate = station.bitrate, bitrate > 0 {
                        BitrateLabelView(bitrate: bitrate)
                    }

                    if let tags = station.tags, !tags.isEmpty {
                        TagsCloudView(
                            tags: Array(tags.prefix(3)),
                            spacing: 4,
                            horizontalPadding: 0
                        )
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)

            if station.isFavorite {
                AppImage.favoriteFilled.view
                    .foregroundStyle(AppColor.favorite.color)
                    .font(.caption)
            }
        }
    }

    private var verticalBody: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                HStack {
                    avatarView
                    VStack {
                        StationNameTextView(name: station.name, size: .h4)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)

                        CountryLabelView(country: station.country)
                            .lineLimit(1)

                        if let bitrate = station.bitrate, bitrate > 0 {
                            BitrateLabelView(bitrate: bitrate)
                        }
                    }
                }

                if let tags = station.tags, !tags.isEmpty {
                    TagsCloudView(
                        tags: Array(tags.prefix(3)),
                        spacing: 4,
                        horizontalPadding: 0,
                        contentAlignment: .center
                    )
                }
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .cornerRadius(12)

            if station.isFavorite {
                AppImage.favoriteFilled.view
                    .foregroundStyle(AppColor.favorite.color)
                    .font(.caption)
            }
        }
    }

    private var avatarView: some View {
        AvatarView(
            image: stationImage,
            initials: String(station.name.prefix(2)),
            size: .m,
            isLoading: isImageLoading
        )
    }
}

#Preview {
    NavigationStack {
        Form {
            Section("Horizontal Layout") {
                List {
                    StationRowView(station: MockStations.jazzRadio)
                    StationRowView(station: MockStations.classical)
                    StationRowView(station: MockStations.rockRadio)
                }
            }

            Section("Vertical Layout") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    StationRowView(layout: .constant(.vertical), station: MockStations.jazzRadio)
                    StationRowView(layout: .constant(.vertical), station: MockStations.classical)
                    StationRowView(layout: .constant(.vertical), station: MockStations.rockRadio)
                }
            }
        }
    }
}
