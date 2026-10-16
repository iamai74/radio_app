struct MockStrings {
    public static let filterAll = "All"
    public static let filterFavorites = "Favorites"
    public static let searchPlaceholder = "Search"
    public static let emptySearchTitle = "No Stations"
    public static let emptySearchSubtitle = "Start searching to find your favorite radio stations"
    public static let emptySearchNoResultsTitle = "No Results Found"
    public static let emptySearchNoResultsSubtitle: @Sendable (String) -> String = { query in
        "No stations match \"\(query)\""
    }
    public static let searchFieldPlaceholder = "Search stations..."

    public static let tagsPreview = ["jazz", "rock", "classical", "pop", "electronic", "hip-hop", "country"]
    public static let tagsSelectedPreview = ["rock"]

    public static let tagJazz = "Jazz"
    public static let tagRock = "Rock"

    public static let textHeading1 = "Heading 1"
    public static let textHeading2 = "Heading 2"
    public static let textHeading3 = "Heading 3"
    public static let textHeading4 = "Heading 4"
    public static let textBase = "Base text"
}
