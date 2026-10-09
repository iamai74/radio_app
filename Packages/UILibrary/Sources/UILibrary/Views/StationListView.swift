import SwiftUI

public struct StationListView: View {
    let stations: [any Station]
    let filterAllTitle: String
    let filterFavoritesTitle: String
    let searchPlaceholder: String
    let emptySearchTitle: String
    let emptySearchSubtitle: String
    let emptySearchNoResultsTitle: String
    let emptySearchNoResultsSubtitle: (String) -> String
    @State private var searchText: String = ""
    @State private var selectedFilter: StationsFilter = .all
    @State private var selectedTags: Set<String> = []

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
        self.searchPlaceholder = searchPlaceholder
        self.emptySearchTitle = emptySearchTitle
        self.emptySearchSubtitle = emptySearchSubtitle
        self.emptySearchNoResultsTitle = emptySearchNoResultsTitle
        self.emptySearchNoResultsSubtitle = emptySearchNoResultsSubtitle
    }

    private var allTags: [String] {
        var tags = Set<String>()
        for station in stations {
            if let stationTags = station.tags {
                tags.formUnion(stationSegment(stationTags))
            }
        }
        return Array(tags).sorted()
    }
    
    private func stationSegment(_ tags: [String]) -> [String] {
        tags
    }

    private var filteredStations: [any Station] {
        var results = stations
        
        // Apply filter
        if selectedFilter == .favorites {
            results = results.filter { $0.isFavorite }
        }
        
        // Apply search text
        if !searchText.isEmpty {
            results = results.filter { station in
                station.name.localizedCaseInsensitiveContains(searchText) ||
                station.country.localizedCaseInsensitiveContains(searchText) ||
                (station.tags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
            }
        }
        
        // Apply tag filter
        if !selectedTags.isEmpty {
            results = results.filter { station in
                guard let stationTags = station.tags else { return false }
                return !selectedTags.isDisjoint(with: Set(stationTags))
            }
        }
        
        return results
    }

    public var body: some View {
        VStack(spacing: 0) {
            StationFilterView(
                filterAllTitle: filterAllTitle,
                filterFavoritesTitle: filterFavoritesTitle,
                selectedFilter: $selectedFilter
            )

            SearchFieldView(placeholder: searchPlaceholder, searchText: $searchText)
            
            if filteredStations.isEmpty {
                NoResultView(
                    title: emptySearchTitle,
                    subtitle: emptySearchSubtitle
                )
            } else {
                StationsListView(stations: filteredStations) { _ in
                    // Handle station selection here if needed
                }
                .listStyle(.plain)
            }
            
            if !allTags.isEmpty {
                TagsCloudView(
                    tags: allTags,
                    selectedTags: selectedTags,
                    onTagTap: { tag in
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                )
                .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    StationListView(
        stations: MockStations.all,
        filterAllTitle: "All",
        filterFavoritesTitle: "Favorites",
        searchPlaceholder: "Search...",
        emptySearchTitle: "No Results",
        emptySearchSubtitle: "Try something else",
        emptySearchNoResultsTitle: "No Results Found",
        emptySearchNoResultsSubtitle: { _ in "No matches for your search" }
    )
}
