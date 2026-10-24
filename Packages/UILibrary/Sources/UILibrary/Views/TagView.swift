import SwiftUI

public struct TagView: View {
    let text: String
    var isSelected: Bool = false
    var size: TextSize?

    private var textStyle: TextColorStyle {
        isSelected ? .white : .primary
    }

    private var backgroundColor: Color {
        isSelected ? Color.accentColor : Color.secondary.opacity(0.15)
    }

    private var effectiveSize: TextSize {
        size ?? .caption
    }

    public var body: some View {
        TextView(text, size: effectiveSize, textStyle: textStyle)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        TagView(text: MockStrings.tagJazz)
        TagView(text: MockStrings.tagRock, isSelected: true)
    }
}
