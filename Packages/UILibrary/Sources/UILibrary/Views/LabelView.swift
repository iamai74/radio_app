import SwiftUI

public enum LabelAlignment {
    case leadingIcon
    case trailingIcon
}

public struct LabelView: View {
    let icon: AppImage
    let text: String
    let size: TextSize
    let textStyle: TextColorStyle
    let alignment: LabelAlignment

    public init(
        icon: AppImage,
        text: String,
        size: TextSize = .base,
        textStyle: TextColorStyle = .primary,
        alignment: LabelAlignment = .leadingIcon
    ) {
        self.icon = icon
        self.text = text
        self.size = size
        self.textStyle = textStyle
        self.alignment = alignment
    }

    public var body: some View {
        HStack(spacing: 8) {
            if alignment == .leadingIcon {
                icon.view
                    .font(.system(size: size.fontSize))
                    .foregroundStyle(textStyle.color)

                TextView(text, size: size, textStyle: textStyle)
            } else {
                TextView(text, size: size, textStyle: textStyle)

                icon.view
                    .font(.system(size: size.fontSize))
                    .foregroundStyle(textStyle.color)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        LabelView(icon: .radio, text: MockStrings.labelRadioStations)
        LabelView(icon: .globe, text: MockStrings.labelBrowseStations, size: .subheadline, textStyle: .secondary)
        LabelView(icon: .heart, text: MockStrings.labelFavorites, alignment: .trailingIcon)
        LabelView(icon: .search, text: MockStrings.labelSearch, size: .caption, textStyle: .accent)
    }
    .padding()
}
