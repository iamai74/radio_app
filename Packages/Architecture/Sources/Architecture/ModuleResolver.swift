import Foundation

public class ModuleResolver: DependencyResolver {
    private var registrations: [ObjectIdentifier: Any] = [:]

    public init() {}

    public func register<T>(_ instance: T, forKey key: ObjectIdentifier) {
        registrations[key] = instance
    }

    public func register<T>(_ instance: T) {
        registrations[ObjectIdentifier(T.self)] = instance
    }

    public func resolve<T>(_ type: T.Type) -> T? {
        registrations[ObjectIdentifier(type)] as? T
    }
}
