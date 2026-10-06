import Foundation

/// A protocol representing a language.
///
/// Decoding deliberately stays off the read model: only ``CountedObject`` knows how to turn
/// the payload of the service into a language, while consumers depend on the value
/// properties of ``StationCounted``.
public protocol Language: StationCounted {}
