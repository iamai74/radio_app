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
        List(stations, id: \.id) { station in
            StationRowView(station: station)
                .onTapGesture {
                    onStationSelected(station)
                }
        }
        .listStyle(.plain)
    }
}

#Preview {
    StationsListView(
        stations: MockStations.all
    ) { station in
        print("Selected: \(station.name)")
    }
}
