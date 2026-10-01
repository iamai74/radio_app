// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// No stations found for "%@"
  public static func emptySearchNoResultsSubtitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "empty_search_no_results_subtitle", String(describing: p1), fallback: "No stations found for \"%@\"")
  }
  /// No Results
  public static let emptySearchNoResultsTitle = L10n.tr("Localizable", "empty_search_no_results_title", fallback: "No Results")
  /// Enter a station name, country, or tag
  public static let emptySearchSubtitle = L10n.tr("Localizable", "empty_search_subtitle", fallback: "Enter a station name, country, or tag")
  /// EmptySearch
  public static let emptySearchTitle = L10n.tr("Localizable", "empty_search_title", fallback: "Search Stations")
  /// StationList
  public static let filterAll = L10n.tr("Localizable", "filter_all", fallback: "All")
  /// Favorites
  public static let filterFavorites = L10n.tr("Localizable", "filter_favorites", fallback: "Favorites")
  /// Search
  public static let searchPlaceholder = L10n.tr("Localizable", "search_placeholder", fallback: "Search stations...")
  /// StationRow
  public static func stationRowBitrate(_ p1: Any) -> String {
    return L10n.tr("Localizable", "station_row_bitrate", String(describing: p1), fallback: "%@ kbps")
  }
  /// New
  public static let testNewString = L10n.tr("Localizable", "test_new_string", fallback: "This is a new test string")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
