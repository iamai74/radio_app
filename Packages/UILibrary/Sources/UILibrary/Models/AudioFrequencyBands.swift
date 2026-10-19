import Foundation

public struct AudioFrequencyBands {
    public let bands: [Double]

    public static func empty(count: Int = 32) -> AudioFrequencyBands {
        AudioFrequencyBands(bands: Array(repeating: 0, count: count))
    }

    public static func random(count: Int = 32) -> AudioFrequencyBands {
        AudioFrequencyBands(bands: (0..<count).map { _ in Double.random(in: 0...1) })
    }
}
