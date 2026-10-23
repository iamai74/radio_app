import SwiftUI

struct CloudTag: Identifiable {
    let id = UUID()
    let text: String
    let fontSize: CGFloat
}

struct CloudLine {
    let tags: [CloudTag]
}

public struct TagsCloudView: View {
    let tags: [String]
    var selectedTags: Set<String> = []
    var onTagTap: ((String) -> Void)?
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let contentAlignment: Alignment
    let minFontSize: CGFloat
    let maxFontSize: CGFloat

    public init(
        tags: [String],
        selectedTags: Set<String> = [],
        onTagTap: ((String) -> Void)? = nil,
        spacing: CGFloat = 8,
        horizontalPadding: CGFloat = 0,
        contentAlignment: Alignment = .leading,
        minFontSize: CGFloat = 11,
        maxFontSize: CGFloat = 20
    ) {
        self.tags = tags
        self.selectedTags = selectedTags
        self.onTagTap = onTagTap
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.contentAlignment = contentAlignment
        self.minFontSize = minFontSize
        self.maxFontSize = maxFontSize
    }

    public var body: some View {
        GeometryReader { geometry in
            if tags.isEmpty {
                return AnyView(EmptyView())
            }

            let cloudTags = cloudTagsList
            let lines = computeLines(for: cloudTags, in: geometry.size.width)

            return AnyView(
                VStack(alignment: cloudHorizontalAlignment, spacing: spacing) {
                    ForEach(lines.indices, id: \.self) { index in
                        cloudRow(lines[index])
                    }
                }
            )
        }
        .padding(.horizontal, horizontalPadding)
    }

    private var cloudTagsList: [CloudTag] {
        tags.map { CloudTag(text: $0, fontSize: cloudFontSize(for: $0)) }
    }

    private var cloudHorizontalAlignment: HorizontalAlignment {
        contentAlignment == .center ? .center : .leading
    }

    private func cloudRow(_ line: CloudLine) -> some View {
        HStack(spacing: spacing) {
            ForEach(line.tags) { tag in
                TagView(
                    text: tag.text,
                    isSelected: selectedTags.contains(tag.text)
                )
                .onTapGesture {
                    onTagTap?(tag.text)
                }
            }
        }
    }

    private func cloudFontSize(for tag: String) -> CGFloat {
        let hash = UInt64(bitPattern: Int64(tag.hashValue))
        let range = maxFontSize - minFontSize
        return minFontSize + CGFloat(hash % UInt64(range * 100)) / 100
    }

    private func estimateWidth(for tag: CloudTag) -> CGFloat {
        CGFloat(tag.text.count) * (tag.fontSize * 0.6) + 24
    }

    private func computeLines(for cloudTagsInput: [CloudTag], in width: CGFloat) -> [CloudLine] {
        let availableWidth = width - (horizontalPadding * 2)

        var lines: [CloudLine] = []
        var currentLine: [CloudTag] = []
        var currentLineWidth: CGFloat = 0

        for tag in cloudTagsInput {
            let tagWidth = estimateWidth(for: tag)
            let needsSpace = currentLine.isEmpty ? tagWidth : currentLineWidth + spacing + tagWidth

            if needsSpace > availableWidth && !currentLine.isEmpty {
                lines.append(CloudLine(tags: currentLine))
                currentLine = []
                currentLineWidth = 0
            }

            currentLine.append(tag)
            currentLineWidth = needsSpace
        }

        if !currentLine.isEmpty {
            lines.append(CloudLine(tags: currentLine))
        }

        return lines
    }
}

#Preview {
    VStack(spacing: 32) {
        TagsCloudView(tags: MockStrings.tagsPreview)
        TagsCloudView(
            tags: ["jazz", "rock", "classical", "pop", "electronic", "hip-hop", "country", "metal", "blues", "folk"],
            selectedTags: Set(MockStrings.tagsSelectedPreview)
        )
        TagsCloudView(
            tags: ["ambient", "lo-fi", "synthwave", "chill", "downtempo", "house", "techno", "trance"],
            contentAlignment: .center
        )
    }
    .padding()
}
