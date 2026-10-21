import protocol RadioBrowserAPI.Station

/// The station model of the Radio Browser API.
///
/// The API package names its facade `RadioBrowserAPI`, and that type shadows the
/// module name, so `RadioBrowserAPI.Station` cannot be spelled out in the
/// application layer. The scoped import above resolves the protocol on its own,
/// and the alias gives it a name that does not collide with `UILibrary.Station`.
typealias ApiStation = Station
