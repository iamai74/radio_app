import SwiftUI

public struct NoResultView: View {
    let imageName: String
    let title: String
    let subtitle: String

    public init(
        imageName: String = "magnifyingglass",
        title: String,
        subtitle: String
    ) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: imageName)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            TextView(title, size: .h3)
            TextView(subtitle, size: .base, textStyle: .secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoResultView(
        title: MockStrings.emptySearchTitle,
        subtitle: MockStrings.emptySearchSubtitle
    )
}
