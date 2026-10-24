import SwiftUI

/// View that asynchronously loads an image from a favicon URL and provides it to its content closure.
public struct AsyncImageLoaderView<Content: View>: View {
    private let favicon: String?
    @State private var loadedImage: Image?
    @State private var isLoading: Bool = false
    private let content: (Image?, Bool) -> Content

    public init(
        favicon: String?,
        @ViewBuilder content: @escaping (Image?, Bool) -> Content
    ) {
        self.favicon = favicon
        self.content = content
    }

    public var body: some View {
        content(loadedImage, isLoading)
            .task {
                await load()
            }
    }

    @MainActor
    private func load() async {
        guard let favicon, let url = URL(string: favicon) else {
            return
        }

        isLoading = true

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

#if os(iOS)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
#elseif os(macOS)
            if let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
#endif
        } catch {
            // Ignore loading errors.
        }

        isLoading = false
    }
}
