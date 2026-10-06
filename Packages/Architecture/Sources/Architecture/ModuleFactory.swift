import Foundation

public protocol ModuleFactoryProtocol: AnyObject {
    func makeCoordinator<M: ModuleProtocol>(for moduleType: M.Type, navigator: NavigatorProtocol) -> M.CoordinatorType
}

public class DefaultModuleFactory: ModuleFactoryProtocol {
    private let resolver: any DependencyResolver

    public init(resolver: any DependencyResolver) {
        self.resolver = resolver
    }

    public func makeCoordinator<M: ModuleProtocol>(for moduleType: M.Type, navigator: NavigatorProtocol) -> M.CoordinatorType {
        guard let module = resolver.resolve(moduleType) else {
            fatalError("Module \(M.self) not found in resolver")
        }
        return module.makeCoordinator(navigator: navigator)
    }
}
