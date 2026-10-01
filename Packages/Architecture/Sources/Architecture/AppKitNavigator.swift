import Foundation
import AppKit
import Architecture

public class AppKitNavigator: Navigator {
    private let window: NSWindow

    public init(window: NSWindow) {
        self.window = window
    }

    public func push<V: View>(view: V) where V.ViewModelType: ViewModel {
        fatalError("Push is not natively supported in AppKit window-based navigation in this abstraction")
    }

    public func present<V: View>(view: V) where V.ViewModelType: ViewModel {
        if let viewController = view as? NSViewController {
            window.contentViewController = viewController
        } else {
            fatalError("View must be an NSViewController for AppKitNavigator")
        }
    }

    public func pop() {
        // Not applicable in this simple window-based implementation
    }
}
