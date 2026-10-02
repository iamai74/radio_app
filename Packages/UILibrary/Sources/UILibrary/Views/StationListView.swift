import SwiftUI
import Resources

public enum StationFilter: String, CaseIterable {
    case all
    case favorites
    
    public var displayName: String {
        switch self {
        case .all:
            return R.string.localizable.filter_all()
        case .favorites:
            return R.string.localizable.filter_favorites()
        }
    }
}

public struct StationListView: View {
    let stations: [any Station]
    @State private var selectedFilter: StationFilter = .all
    let searchView: SearchView
    
    public init(stations: [any Station]) {
        self.stations = stations
        self.searchView = SearchView(stations: stations)
    }
    
    private var filteredStations: [any Station] {
        switch selectedFilter {
        case .all:
            return stations
        case .favorites:
            return stations.filter(\.isFavorite)
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(StationFilter.allCases, id: \.self) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)
            
            List(filteredStations, id: \.id) { station in
                StationRowView(station: station)
            }
            .listStyle(.plain)
            
            HStack {
                Spacer()
                Button {
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                .controlSize(.large)
                .padding()
            }
        }
    }
}

#Preview {
    StationListView(stations: MockStations.all)
}
