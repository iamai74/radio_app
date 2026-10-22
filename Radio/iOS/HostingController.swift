import SwiftUI
import UIKit

final class HostingController<Content: View>: UIHostingController<Content> {
    @available(iOS 27.1, *)
    override var preferredVerticalBarBehavior: UIVerticalBarBehavior {
        .disabled
    }
}
