import SwiftUI

public struct StationRowView: View {
    let station: any Station

    public var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: station.favicon ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "radio")
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.1))
            )

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
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
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
