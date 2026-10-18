import SwiftUI

public struct AvatarView: View {
    public enum Size {
        case xxs
        case xs
        case s
        case m
        case l
        case xl
        case xxl

        var diameter: CGFloat {
            switch self {
            case .xxs: 24
            case .xs: 32
            case .s: 40
            case .m: 56
            case .l: 72
            case .xl: 96
            case .xxl: 128
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .xxs: 10
            case .xs: 12
            case .s: 14
            case .m: 20
            case .l: 28
            case .xl: 36
            case .xxl: 48
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .xxs: 6
            case .xs: 8
            case .s: 10
            case .m: 14
            case .l: 18
            case .xl: 24
            case .xxl: 32
            }
        }
    }

    let initials: String
    let size: Size
    let backgroundColor: Color
    var image: Image?
    var isLoading: Bool

    public init(
        image: Image? = nil,
        initials: String = "",
        size: Size = .m,
        backgroundColor: Color = .accentColor,
        isLoading: Bool = false
    ) {
        self.image = image
        self.initials = initials
        self.size = size
        self.backgroundColor = backgroundColor
        self.isLoading = isLoading
    }

    public func image(_ image: Image?) -> AvatarView {
        var view = self
        view.image = image
        return view
    }

    public func isLoading(_ isLoading: Bool) -> AvatarView {
        var view = self
        view.isLoading = isLoading
        return view
    }

    public var body: some View {
        ZStack {
            backgroundColor

            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            } else if !initials.isEmpty && !isLoading {
                Text(initials.prefix(2).uppercased())
                    .font(.system(size: size.fontSize, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
            }

            if isLoading {
                LoadingIndicator(isLoading: true, size: loadingIndicatorSize)
            }
        }
        .frame(width: size.diameter, height: size.diameter)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
    }

    private var loadingIndicatorSize: LoadingIndicator.Size {
        switch size {
        case .xxs, .xs, .s:
            return .small
        case .m:
            return .medium
        case .l, .xl, .xxl:
            return .large
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        AvatarView(initials: "AB", size: .xxs)
        AvatarView(initials: "AB", size: .xs)
        AvatarView(initials: "AB", size: .s)
        AvatarView(initials: "AB", size: .m)
        AvatarView(initials: "AB", size: .l)
        AvatarView(initials: "AB", size: .xl)
        AvatarView(initials: "AB", size: .xxl)

        AvatarView(initials: "LD", size: .m, isLoading: true)

        HStack(spacing: 16) {
            AvatarView(initials: "R", size: .m, backgroundColor: .red)
            AvatarView(initials: "G", size: .m, backgroundColor: .green)
            AvatarView(initials: "B", size: .m, backgroundColor: .blue)
        }

        HStack(spacing: 16) {
            AvatarView(initials: "A", size: .xxs)
            AvatarView(initials: "B", size: .xs)
            AvatarView(initials: "C", size: .s)
            AvatarView(initials: "D", size: .m)
            AvatarView(initials: "E", size: .l)
        }
    }
    .padding()
}
