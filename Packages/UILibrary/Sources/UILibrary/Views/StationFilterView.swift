import SwiftUI

public enum StationsFilter: String, CaseIterable {
    case all
    case favorites
}

public struct StationFilterView: View {
    let filterAllTitle: String
    let filterFavoritesTitle: String
    @Binding var selectedFilter: StationsFilter
    
    private var filterDisplayName: [StationsFilter: String] {
        [
            .all: filterAllTitle,
            .favorites: filterFavoritesTitle
        ]
    }
    
    public init(
        filterAllTitle: String,
        filterFavoritesTitle: String,
        selectedFilter: Binding<StationsFilter>
    ) {
        self.filterAllTitle = filterAllTitle
        self.filterFavoritesTitle = filterFavoritesTitle
        self._selectedFilter = selectedFilter
    }
    
    public var body: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(StationsFilter.allCases, id: \.self) { filter in
                Text(filterDisplayName[filter] ?? filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    @State var selectedFilter = StationsFilter.all
    return StationFilterView(
        filterAllTitle: MockStrings.filterAll,
        filterFavoritesTitle: MockStrings.filterFavorites,
        selectedFilter: $selectedFilter
    )
}
