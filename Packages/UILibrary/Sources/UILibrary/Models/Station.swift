import Foundation

public protocol Station: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var url: String { get }
    var homepage: String? { get }
    var favicon: String? { get }
    var tags: [String]? { get }
    var country: String { get }
    var state: String? { get }
    var language: String? { get }
    var votes: Int { get }
    var bitrate: Int? { get }
    var lastCheckOk: Bool { get }
    var isFavorite: Bool { get }
}
