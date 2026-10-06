import SwiftUI

public enum StationFilter: String, CaseIterable {
    case all
    case favorites
}

public struct StationListView: View {
    let stations: [any Station]
    let filterAllTitle: String
    let filterFavoritesTitle: String
    let searchView: SearchView
    @State private var selectedFilter: StationFilter = .all

    public init(
        stations: [any Station],
        filterAllTitle: String,
        filterFavoritesTitle: String,
        searchPlaceholder: String,
        emptySearchTitle: String,
        emptySearchSubtitle: String,
        emptySearchNoResultsTitle: String,
        emptySearchNoResultsSubtitle: @escaping (String) -> String
    ) {
        self.stations = stations
        self.filterAllTitle = filterAllTitle
        self.filterFavoritesTitle = filterFavoritesTitle
        self.searchView = SearchView(
            stations: stations,
            searchPlaceholder: searchPlaceholder,
            emptySearchTitle: emptySearchTitle,
            emptySearchSubtitle: emptySearchSubtitle,
            emptySearchNoResultsTitle: emptySearchNoResultsTitle,
            emptySearchNoResultsSubtitle: emptySearchNoResultsSubtitle
        )
    }

    private var filteredStations: [any Station] {
        switch selectedFilter {
        case .all:
            return stations
        case .favorites:
            return stations.filter(\.isFavorite)
        }
    }

    private var filterDisplayName: [StationFilter: String] {
        [
            .all: filterAllTitle,
            .favorites: filterFavoritesTitle
        ]
    }

    public var body: some View {
        VStack(spacing: 0) {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(StationFilter.allCases, id: \.self) { filter in
                    Text(filterDisplayName[filter] ?? filter.rawValue).tag(filter)
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
    StationListView(
        stations: MockStations.all,
        filterAllTitle: UILibraryStrings.filterAll,
        filterFavoritesTitle: UILibraryStrings.filterFavorites,
        searchPlaceholder: UILibraryStrings.searchPlaceholder,
        emptySearchTitle: UILibraryStrings.emptySearchTitle,
        emptySearchSubtitle: UILibraryStrings.emptySearchSubtitle,
        emptySearchNoResultsTitle: UILibraryStrings.emptySearchNoResultsTitle,
        emptySearchNoResultsSubtitle: UILibraryStrings.emptySearchNoResultsSubtitle
    )
}
