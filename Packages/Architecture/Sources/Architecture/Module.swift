import Foundation

public protocol ModuleProtocol: AnyObject {
    associatedtype CoordinatorType: CoordinatorProtocol

    func makeCoordinator(navigator: NavigatorProtocol) -> CoordinatorType
}
