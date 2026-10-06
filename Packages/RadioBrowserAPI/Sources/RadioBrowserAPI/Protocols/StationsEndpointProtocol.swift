import Foundation

/// A protocol defining the interface for interacting with radio station endpoints.
///
/// The protocol is a composition of capabilities: a consumer that only searches declares
/// `any StationSearching`, one that browses declares `any StationFetching`, and the
/// facade exposes the composition. Every capability except ``StationLookup`` is provided
/// as a default implementation over ``StationRequesting``, so conformers implement two
/// methods at most.
public protocol StationsEndpointProtocol: StationFetching, StationSearching, StationLookup {}
