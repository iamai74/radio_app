import SwiftUI
import AppKit
import Architecture

@MainActor
final class MacOSNavigator: NavigatorProtocol {
    private static let defaultContentSize = NSSize(width: 800, height: 600)

    private weak var window: NSWindow?
    private var stack: [NSViewController] = []

    init(window: NSWindow) {
        self.window = window
    }

    func setRoot<V: ViewProtocol>(view: V) {
        let controller = NSHostingController(rootView: view)
        stack = [controller]
        window?.contentViewController = controller
        restoreContentSizeIfNeeded()
    }

    func push<V: ViewProtocol>(view: V) {
        let controller = NSHostingController(rootView: view)
        stack.append(controller)
        window?.contentViewController = controller
        restoreContentSizeIfNeeded()
    }

    func present<V: ViewProtocol>(view: V) {
        let controller = NSHostingController(rootView: view)
        window?.contentViewController?.presentAsSheet(controller)
    }

    func pop() {
        guard stack.count > 1 else { return }
        stack.removeLast()
        window?.contentViewController = stack.last
        restoreContentSizeIfNeeded()
    }

    private func restoreContentSizeIfNeeded() {
        guard let window else { return }
        let size = window.contentLayoutRect.size
        guard size.width < Self.defaultContentSize.width / 2 || size.height < Self.defaultContentSize.height / 2 else { return }
        window.setContentSize(Self.defaultContentSize)
        window.center()
    }
}
