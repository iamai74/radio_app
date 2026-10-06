import Foundation

/// A protocol representing a tag.
///
/// The name is deliberately `StationTag` and not `Tag`: a library type called `Tag` shadows
/// Swift Testing's own `Tag` in every test file that imports both modules.
///
/// Decoding deliberately stays off the read model: only ``CountedObject`` knows how to turn
/// the payload of the service into a tag, while consumers depend on the value properties of
/// ``StationCounted``.
public protocol StationTag: StationCounted {}
