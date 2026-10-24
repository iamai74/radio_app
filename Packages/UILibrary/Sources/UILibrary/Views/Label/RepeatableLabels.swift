import SwiftUI

public struct CountryLabelView: View {
    let country: String
    let size: TextSize
    let textStyle: TextColorStyle

    public init(
        country: String,
        size: TextSize = .subheadline,
        textStyle: TextColorStyle = .secondary
    ) {
        self.country = country
        self.size = size
        self.textStyle = textStyle
    }

    public var body: some View {
        LabelView(
            icon: .globe,
            text: country,
            size: size,
            textStyle: textStyle
        )
    }
}

public struct BitrateLabelView: View {
    let bitrate: Int
    let size: TextSize
    let textStyle: TextColorStyle

    public init(
        bitrate: Int,
        size: TextSize = .caption,
        textStyle: TextColorStyle = .secondary
    ) {
        self.bitrate = bitrate
        self.size = size
        self.textStyle = textStyle
    }

    public var body: some View {
        LabelView(
            icon: .gauge,
            text: "\(bitrate) kbps",
            size: size,
            textStyle: textStyle
        )
    }
}
