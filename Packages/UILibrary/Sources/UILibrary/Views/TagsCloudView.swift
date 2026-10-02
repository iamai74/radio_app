import SwiftUI

public struct TagsCloudView: View {
    let tags: [String]
    var selectedTags: Set<String> = []
    var onTagTap: ((String) -> Void)?

    public init(
        tags: [String],
        selectedTags: Set<String> = [],
        onTagTap: ((String) -> Void)? = nil
    ) {
        self.tags = tags
        self.selectedTags = selectedTags
        self.onTagTap = onTagTap
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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
            .padding(.horizontal)
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
