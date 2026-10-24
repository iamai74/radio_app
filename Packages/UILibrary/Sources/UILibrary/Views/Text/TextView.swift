import SwiftUI

public struct TextView: View {
	let text: String
	let size: TextSize
	let textStyle: TextColorStyle

	public init(_ text: String, size: TextSize = .base, textStyle: TextColorStyle = .primary) {
		self.text = text
		self.size = size
		self.textStyle = textStyle
	}

	public var body: some View {
		Text(text)
			.font(.system(size: size.fontSize, design: .default))
			.fontWeight(size.fontWeight)
			.foregroundStyle(textStyle.color)
	}
}

#Preview {
	VStack(alignment: .leading, spacing: 16) {
		TextView(MockStrings.textHeading1, size: .h1)
		TextView(MockStrings.textHeading2, size: .h2)
		TextView(MockStrings.textHeading3, size: .h3)
		TextView(MockStrings.textHeading4, size: .h4)
		TextView(MockStrings.textBase, size: .base)
		TextView("Secondary", size: .base, textStyle: .secondary)
		TextView("Caption", size: .caption, textStyle: .white)
			.padding(8)
			.background(Color.accentColor)
			.clipShape(Capsule())
	}
	.padding()
}
