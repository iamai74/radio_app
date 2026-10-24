import SwiftUI

public enum TextSize {
	case h1
	case h2
	case h3
	case h4
	case `base`
	case subheadline
	case caption

	public var fontSize: Double {
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

	public var fontWeight: Font.Weight {
		switch self {
		case .h1, .h2, .h3, .h4:
			.semibold
		case .base, .subheadline, .caption:
			.regular
		}
	}
}

public enum TextColorStyle {
	case primary
	case secondary
	case accent
	case white

	public var color: Color {
		switch self {
		case .primary: .primary
		case .secondary: .secondary
		case .accent: .accentColor
		case .white: .white
		}
	}
}
