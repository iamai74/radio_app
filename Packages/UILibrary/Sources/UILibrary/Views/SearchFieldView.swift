import SwiftUI

public struct SearchFieldView: View {
    let placeholder: String
    @Binding var searchText: String
    
    public init(
        placeholder: String,
        searchText: Binding<String>
    ) {
        self.placeholder = placeholder
        self._searchText = searchText
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $searchText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    @State var searchText = ""
    return SearchFieldView(
        placeholder: MockStrings.searchPlaceholder,
        searchText: $searchText
    )
}
