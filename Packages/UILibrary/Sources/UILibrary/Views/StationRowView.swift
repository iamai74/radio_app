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
                Text(station.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(station.country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if let tags = station.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(tags.prefix(3), id: \.self) { tag in
                                TagView(text: tag)
                            }
                        }
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let bitrate = station.bitrate, bitrate > 0 {
                    Text("\(bitrate) kbps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
