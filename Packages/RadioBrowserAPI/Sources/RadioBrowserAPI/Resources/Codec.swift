import Foundation

/// A protocol representing an audio codec.
///
/// Decoding deliberately stays off the read model: only ``CountedObject`` knows how to turn
/// the payload of the service into a codec, while consumers depend on the value properties
/// of ``StationCounted``.
public protocol Codec: StationCounted {}
