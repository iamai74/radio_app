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
                Text(R.string.localizable.empty_search_title())
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(R.string.localizable.empty_search_subtitle())
                    .foregroundStyle(.secondary)
            } else {
                Text(R.string.localizable.empty_search_no_results_title())
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(R.string.localizable.empty_search_no_results_subtitle(searchText))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptySearchView(searchText: "")
}
