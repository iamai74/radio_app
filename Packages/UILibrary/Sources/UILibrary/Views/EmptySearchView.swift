import SwiftUI

public struct EmptySearchView: View {
    let searchText: String
    let title: String
    let subtitle: String
    let noResultsTitle: String
    let noResultsSubtitle: (String) -> String

    public init(
        searchText: String,
        title: String,
        subtitle: String,
        noResultsTitle: String,
        noResultsSubtitle: @escaping (String) -> String
    ) {
        self.searchText = searchText
        self.title = title
        self.subtitle = subtitle
        self.noResultsTitle = noResultsTitle
        self.noResultsSubtitle = noResultsSubtitle
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            if searchText.isEmpty {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .foregroundStyle(.secondary)
            } else {
                Text(noResultsTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(noResultsSubtitle(searchText))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptySearchView(
        searchText: "",
        title: UILibraryStrings.emptySearchTitle,
        subtitle: UILibraryStrings.emptySearchSubtitle,
        noResultsTitle: UILibraryStrings.emptySearchNoResultsTitle,
        noResultsSubtitle: UILibraryStrings.emptySearchNoResultsSubtitle
    )
}
