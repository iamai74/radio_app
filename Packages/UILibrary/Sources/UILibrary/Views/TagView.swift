import SwiftUI

public struct TagView: View {
    let text: String
    var isSelected: Bool = false
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        TagView(text: "Jazz")
        TagView(text: "Rock", isSelected: true)
    }
}
