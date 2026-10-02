import SwiftUI
import Resources

public struct SearchView: View {
    let stations: [any Station]
    @State private var searchText: String = ""
    @State private var selectedTags: Set<String> = []
    
    public init(stations: [any Station]) {
        self.stations = stations
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
                EmptySearchView(searchText: searchText)
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
                EmptySearchView(searchText: searchText)
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
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(R.string.localizable.search_placeholder(), text: $searchText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    SearchView(stations: MockStations.all)
}
