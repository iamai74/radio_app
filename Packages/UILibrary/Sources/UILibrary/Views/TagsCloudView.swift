import SwiftUI

public struct TagsCloudView: View {
    let tags: [String]
    var selectedTags: Set<String> = []
    var onTagTap: ((String) -> Void)?
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let contentAlignment: Alignment
    
    public init(
        tags: [String],
        selectedTags: Set<String> = [],
        onTagTap: ((String) -> Void)? = nil,
        spacing: CGFloat = 8,
        horizontalPadding: CGFloat = 0,
        contentAlignment: Alignment = .leading
    ) {
        self.tags = tags
        self.selectedTags = selectedTags
        self.onTagTap = onTagTap
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.contentAlignment = contentAlignment
    }
    
    public var body: some View {
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

#Preview {
    VStack {
        TagsCloudView(tags: MockStrings.tagsPreview)
        TagsCloudView(
            tags: ["jazz", "rock", "classical"],
            selectedTags: Set(MockStrings.tagsSelectedPreview)
        )
    }
}
