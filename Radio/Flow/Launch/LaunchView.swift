import SwiftUI
import Architecture
import Resources

struct LaunchView: ViewProtocol {
    let viewModel: LaunchViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text(R.string.localizable.app_name())
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("Loading…")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
