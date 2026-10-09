import SwiftUI

public struct SearchView: View {
    let stations: [any Station]
    let searchPlaceholder: String
    let emptySearchTitle: String
    let emptySearchSubtitle: String
    let emptySearchNoResultsTitle: String
    let emptySearchNoResultsSubtitle: (String) -> String
    @State private var searchText: String = ""
    @State private var selectedTags: Set<String> = []

    public init(
        stations: [any Station],
        searchPlaceholder: String,
        emptySearchTitle: String,
        emptySearchSubtitle: String,
        emptySearchNoResultsTitle: String,
        emptySearchNoResultsSubtitle: @escaping (String) -> String
    ) {
        self.stations = stations
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
                tags.formUnion(stationTags)
            }
        }
        return Array(tags).sorted()
    }

    private var filteredStations: [any Station] {
        var results = stations

        if !searchText.isEmpty {
            results = results.filter { station in
                station.name.localizedCaseInsensitiveContains(searchText) ||
                station.country.localizedCaseInsensitiveContains(searchText) ||
                (station.tags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
            }
        }

        if !selectedTags.isEmpty {
            results = results.filter { station in
                guard let stationTags = station.tags else { return false }
                return !selectedTags.isDisjoint(with: Set(stationTags))
            }
        }

        return results
    }

    #if os(iOS)
    public var body: some View {
        VStack(spacing: 0) {
            if filteredStations.isEmpty {
                NoResultView(
                    title: searchText.isEmpty ? emptySearchTitle : emptySearchNoResultsTitle,
                    subtitle: searchText.isEmpty ? emptySearchSubtitle : emptySearchNoResultsSubtitle(searchText)
                )
            } else {
                List(filteredStations, id: \.id) { station in
                    StationRowView(station: station)
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

            searchField
        }
    }
    #else
    public var body: some View {
        VStack(spacing: 0) {
            searchField

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

            if filteredStations.isEmpty {
                NoResultView(
                    title: searchText.isEmpty ? emptySearchTitle : emptySearchNoResultsTitle,
                    subtitle: searchText.isEmpty ? emptySearchSubtitle : emptySearchNoResultsSubtitle(searchText)
                )
            } else {
                List(filteredStations, id: \.id) { station in
                    StationRowView(station: station)
                }
                .listStyle(.plain)
            }
        }
    }
    #endif

    private var searchField: some View {
        SearchFieldView(placeholder: searchPlaceholder, searchText: $searchText)
    }
}

#Preview {
    SearchView(
        stations: MockStations.all,
        searchPlaceholder: MockStrings.searchPlaceholder,
        emptySearchTitle: MockStrings.emptySearchTitle,
        emptySearchSubtitle: MockStrings.emptySearchSubtitle,
        emptySearchNoResultsTitle: MockStrings.emptySearchNoResultsTitle,
        emptySearchNoResultsSubtitle: MockStrings.emptySearchNoResultsSubtitle
    )
}
