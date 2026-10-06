public struct UILibraryStrings {
    public static let filterAll = "All"
    public static let filterFavorites = "Favorites"
    public static let searchPlaceholder = "Search"
    public static let emptySearchTitle = "No Stations"
    public static let emptySearchSubtitle = "Start searching to find your favorite radio stations"
    public static let emptySearchNoResultsTitle = "No Results Found"
    public static let emptySearchNoResultsSubtitle: @Sendable (String) -> String = { query in
        "No stations match \"\(query)\""
    }
}
