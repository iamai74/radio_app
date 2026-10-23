import SwiftUI

public struct StationsListView: View {
    let stations: [any Station]
    let onStationSelected: (any Station) -> Void

    public init(
        stations: [any Station],
        onStationSelected: @escaping (any Station) -> Void
    ) {
        self.stations = stations
        self.onStationSelected = onStationSelected
    }

    public var body: some View {
        GeometryReader { geometry in
            let columns = columnCount(for: geometry.size.width)

            ScrollView {
                LazyVGrid(columns: gridItems(columns: columns), spacing: 12) {
                    ForEach(stations, id: \.id) { station in
                        StationRowView(layout: .constant(.vertical), station: station)
                            .onTapGesture {
                                onStationSelected(station)
                            }
                    }
                }
                .padding(12)
            }
            .scrollContentBackground(.hidden)
        }
    }

    private func columnCount(for width: CGFloat) -> Int {
        if width < 500 {
            return 1
        } else if width < 700 {
            return 2
        } else if width < 1050 {
            return 3
        } else {
            return 4
        }
    }

    private func gridItems(columns count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: nil), count: count)
    }
}

#Preview {
    StationsListView(
        stations: MockStations.all
    ) { station in
        print("Selected: \(station.name)")
    }
}
