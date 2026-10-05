import Foundation

/// Common shape of the four facet kinds (country, tag, language, codec).
///
/// Deliberately not `Sendable`: the SwiftData implementations are
/// `PersistentModel`s, which the SDK forbids from being `Sendable`. Crossing to
/// the background writer is handled explicitly by `Storage`'s detached-model
/// box instead of by a protocol-level guarantee that would be a lie.
public protocol FacetEntity {
    var name: String { get }
    var stationCount: Int { get }
}
