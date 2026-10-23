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
        if tags.isEmpty {
            EmptyView()
        } else {
            TagFlowLayout(spacing: spacing, alignment: flowAlignment) {
                ForEach(tags.indices, id: \.self) { index in
                    let tag = tags[index]

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

    private var flowAlignment: TagFlowLayout.Alignment {
        contentAlignment == .center ? .center : .leading
    }
}

private struct TagFlowLayout: Layout {
    enum Alignment {
        case leading
        case center
    }

    let spacing: CGFloat
    let alignment: Alignment

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let availableWidth = proposal.width ?? .infinity
        let rows = makeRows(subviews: subviews, availableWidth: availableWidth)
        let height = rows.reduce(0) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        let contentWidth = rows.map(\.width).max() ?? 0
        let width = availableWidth.isFinite ? min(contentWidth, availableWidth) : contentWidth
        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = makeRows(subviews: subviews, availableWidth: bounds.width)
        var originY = bounds.minY

        for row in rows {
            var originX = bounds.minX

            if alignment == .center {
                originX += max((bounds.width - row.width) / 2, 0)
            }

            for item in row.items {
                let itemOriginY = originY + (row.height - item.size.height) / 2
                subviews[item.index].place(
                    at: CGPoint(x: originX, y: itemOriginY),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                originX += item.size.width + spacing
            }

            originY += row.height + spacing
        }
    }

    private func makeRows(subviews: Subviews, availableWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()

        for index in subviews.indices {
            let item = Item(index: index, size: subviews[index].sizeThatFits(.unspecified))
            let requiredWidth = currentRow.items.isEmpty
                ? item.size.width
                : currentRow.width + spacing + item.size.width

            if requiredWidth > availableWidth && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }

            currentRow.append(item, spacing: spacing)
        }

        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    private struct Item {
        let index: Int
        let size: CGSize
    }

    private struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0

        mutating func append(_ item: Item, spacing: CGFloat) {
            if !items.isEmpty {
                width += spacing
            }

            items.append(item)
            width += item.size.width
            height = max(height, item.size.height)
        }
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
