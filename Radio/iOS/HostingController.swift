import SwiftUI
import UIKit
import Resources

final class HostingController<Content: View>: UIHostingController<Content> {
   @available(iOS 27.1, *)
   override var preferredVerticalBarBehavior: UIVerticalBarBehavior {
       .disabled
   }

   override func viewDidLoad() {
       super.viewDidLoad()
       navigationItem.title = R.string.localizable.app_name()
   }
}
