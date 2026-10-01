import SwiftUI
import Resources

public struct EmptySearchView: View {
    let searchText: String
    
    public init(searchText: String) {
        self.searchText = searchText
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            if searchText.isEmpty {
                Text(L10n.emptySearchTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(L10n.emptySearchSubtitle)
                    .foregroundStyle(.secondary)
            } else {
                Text(L10n.emptySearchNoResultsTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(L10n.emptySearchNoResultsSubtitle(searchText))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptySearchView(searchText: "")
}
