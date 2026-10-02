import Foundation
import Architecture
import NeedleFoundation

public protocol Module<Component> {
    associatedtype Component: NeedleFoundation.Component
    associatedtype CoordinatorType: Coordinator

    func makeCoordinator(component: Component) -> CoordinatorType
}
