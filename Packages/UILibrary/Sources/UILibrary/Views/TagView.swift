import SwiftUI

public struct TagView: View {
    let text: String
    var isSelected: Bool = false
    var fontSize: CGFloat?

    private var style: TextStyle {
        isSelected ? .white : .primary
    }

    private var backgroundColor: Color {
        isSelected ? Color.accentColor : Color.secondary.opacity(0.15)
    }

    private var effectiveFontSize: CGFloat {
        fontSize ?? Size.caption.fontSize
    }

    public var body: some View {
        Text(text)
            .font(.system(size: effectiveFontSize, design: .default))
            .fontWeight(.regular)
            .foregroundStyle(style.color)
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
