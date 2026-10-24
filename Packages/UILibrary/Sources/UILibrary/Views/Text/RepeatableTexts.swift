import SwiftUI

public struct StationNameTextView: View {
    let name: String
    let size: TextSize

    public init(
        name: String,
        size: TextSize
    ) {
        self.name = name
        self.size = size
    }

    public var body: some View {
        TextView(name, size: size)
    }
}
