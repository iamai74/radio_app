import SwiftUI
import Architecture
import Resources
import UILibrary

struct LaunchView: ViewProtocol {
    let viewModel: LaunchViewModel

    var body: some View {
        VStack(spacing: 12) {
            TextView(R.string.localizable.app_name(), size: .h1)
            TextView("Loading…", size: .base, textStyle: .secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
