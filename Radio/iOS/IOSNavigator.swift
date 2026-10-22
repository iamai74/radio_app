import SwiftUI
import UIKit
import Architecture

@MainActor
final class IOSNavigator: NavigatorProtocol {
    private let navigationController: UINavigationController

    init(window: UIWindow) {
        navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func setRoot<V: ViewProtocol>(view: V) {
        navigationController.setViewControllers([HostingController(rootView: view)], animated: false)
    }

    func push<V: ViewProtocol>(view: V) {
        navigationController.pushViewController(HostingController(rootView: view), animated: true)
    }

    func present<V: ViewProtocol>(view: V) {
        navigationController.present(HostingController(rootView: view), animated: true)
    }

    func pop() {
        navigationController.popViewController(animated: true)
    }
}
