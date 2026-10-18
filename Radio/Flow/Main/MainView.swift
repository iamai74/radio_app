import SwiftUI
import Architecture
import Resources
import UILibrary

struct MainView: ViewProtocol {
    let viewModel: MainViewModel

    var body: some View {
        VStack(spacing: 12) {
            TextView("R.string.localizable.app_name()", size: .h1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
