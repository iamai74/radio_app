import Foundation
import UIKit
import Architecture

public class UIKitNavigator: Navigator {
    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func push<V: View>(view: V) where V.ViewModelType: ViewModel {
        if let viewController = view as? UIViewController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            // In a real scenario, we'd wrap the SwiftUI view in a UIHostingController
            // But for the requirement of "native" navigation, we assume the view is a UIViewController
            fatalError("View must be a UIViewController for UIKitNavigator")
        }
    }

    public func present<V: View>(view: V) where V.ViewModelType: ViewModel {
        if let viewController = view as (UIViewController) as? UIViewController {
            navigationController.present(viewController, animated: true)
        } else {
            fatalError("View must be a UIViewController for UIKitNavigator")
        }
    }

    public func pop() {
        navigationController.popViewController(animated: true)
    }
}
