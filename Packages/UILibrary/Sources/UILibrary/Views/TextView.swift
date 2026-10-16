import SwiftUI

public enum Size {
	case h1
	case h2
	case h3
	case h4
	case `base`
	case subheadline
	case caption

	var fontSize: Double {
		switch self {
		case .h1: 34
		case .h2: 28
		case .h3: 22
		case .h4: 18
		case .base: 17
		case .subheadline: 15
		case .caption: 12
		}
	}

	var fontWeight: Font.Weight {
		switch self {
		case .h1, .h2, .h3, .h4:
			.semibold
		case .base, .subheadline, .caption:
			.regular
		}
	}
}

public enum TextStyle {
	case primary
	case secondary
	case accent
	case white

	var color: Color {
		switch self {
		case .primary: .primary
		case .secondary: .secondary
		case .accent: .accentColor
		case .white: .white
		}
	}
}

public struct TextView: View {
	let text: String
	let size: Size
	let textStyle: TextStyle

	public init(_ text: String, size: Size = .base, textStyle: TextStyle = .primary) {
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
