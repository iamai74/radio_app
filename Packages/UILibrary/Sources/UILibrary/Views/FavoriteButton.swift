import SwiftUI

public struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    let action: (Bool) -> Void

    public init(
        isFavorite: Binding<Bool>,
        action: @escaping (Bool) -> Void = { _ in }
    ) {
        self._isFavorite = isFavorite
        self.action = action
    }

    public var body: some View {
        Button(action: {
            isFavorite.toggle()
            action(isFavorite)
        }, label: {
            Image(systemName: isFavorite ? AppImage.favoriteFilled.name : AppImage.favoriteUnfilled.name)
                .foregroundColor(isFavorite ? .yellow : .secondary)
                .scaleEffect(isFavorite ? 1.2 : 1)
        })
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isFavorite)
    }
}

#Preview {
    VStack(spacing: 24) {
        FavoriteButton(isFavorite: .constant(false))
        FavoriteButton(isFavorite: .constant(true))
    }
}
