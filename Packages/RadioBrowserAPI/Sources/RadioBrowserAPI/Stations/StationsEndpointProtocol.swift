import Foundation

/// A protocol defining the interface for interacting with radio station endpoints.
///
/// The protocol is a composition of capabilities: a consumer that only searches declares
/// `any StationSearching`, one that browses declares `any StationFetching`, and the
/// facade exposes the composition. Conformers implement the capability methods themselves —
/// the route-executing primitive stayed behind the package boundary, so a consumer or a
/// test double sees only the calls it can actually make.
public protocol StationsEndpointProtocol: StationFetching, StationSearching, StationLookup {}
