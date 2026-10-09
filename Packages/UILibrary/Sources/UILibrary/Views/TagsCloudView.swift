import SwiftUI

public struct TagsCloudView: View {
    let tags: [String]
    var selectedTags: Set<String> = []
    var onTagTap: ((String) -> Void)?
    let spacing: CGFloat
    let horizontalPadding: CGFloat

    public init(
        tags: [String],
        selectedTags: Set<String> = [],
        onTagTap: ((String) -> Void)? = nil,
        spacing: CGFloat = 8,
        horizontalPadding: CGFloat = 0
    ) {
        self.tags = tags
        self.selectedTags = selectedTags
        self.onTagTap = onTagTap
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(tags, id: \.self) { tag in
                    TagView(
                        text: tag,
                        isSelected: selectedTags.contains(tag)
                    )
                    .onTapGesture {
                        onTagTap?(tag)
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}

#Preview {
    VStack {
        TagsCloudView(tags: ["jazz", "rock", "classical", "pop", "electronic", "hip-hop", "country"])
        TagsCloudView(
            tags: ["jazz", "rock", "classical"],
            selectedTags: ["rock"]
        )
    }
}
