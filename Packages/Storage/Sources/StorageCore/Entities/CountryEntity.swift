import Foundation

public protocol CountryEntity: FacetEntity, Sendable {
    var iso31661: String { get }
}
