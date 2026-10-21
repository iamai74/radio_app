import SwiftUI
import Architecture
import Resources
import UILibrary

struct LaunchView: ViewProtocol {
    let viewModel: LaunchViewModel

    var body: some View {
        VStack(spacing: 12) {
            TextView(R.string.localizable.app_name(), size: .h1)
            LoadingIndicator(isLoading: true, size: .medium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            SeaSurfGradientView()
        }
    }
}

#if DEBUG
#Preview {
    LaunchView(viewModel: LaunchViewModel())
}
#endif
