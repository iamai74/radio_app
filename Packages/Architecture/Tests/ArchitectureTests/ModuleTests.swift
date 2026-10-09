import XCTest
import Combine
import SwiftUI

@testable import Architecture

@MainActor
final class ModuleTests: XCTestCase {
    class MockNavigator: NavigatorProtocol {
        func setRoot<V: ViewProtocol>(view: V) {}
        func push<V: ViewProtocol>(view: V) {}
        func present<V: ViewProtocol>(view: V) {}
        func pop() {}
    }

    class MockViewModel: ViewModelProtocol {
        typealias Input = String
        typealias Output = Bool

        func transform(input: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
            input.map { _ in true }.eraseToAnyPublisher()
        }
    }

    final class MockView: ViewProtocol {
        var viewModel: MockViewModel = MockViewModel()

        var body: some View {
            EmptyView()
        }
    }

    class MockCoordinator: CoordinatorProtocol {
        var navigator: NavigatorProtocol
        init(navigator: NavigatorProtocol) {
            self.navigator = navigator
        }
        func start() {}
    }

    class MockModule: ModuleProtocol {
        func makeCoordinator(navigator: NavigatorProtocol) -> MockCoordinator {
            MockCoordinator(navigator: navigator)
        }
    }

    func testModuleCoordinatorCreation() {
        let navigator = MockNavigator()
        let module = MockModule()
        let coordinator = module.makeCoordinator(navigator: navigator)

        XCTAssertNotNil(coordinator)
        XCTAssertTrue(coordinator is MockCoordinator)
    }

    func testModuleResolverRegistrationAndResolution() {
        let resolver = ModuleResolver()

        class SomeModule: ModuleProtocol {
            func makeCoordinator(navigator: NavigatorProtocol) -> SomeCoordinator {
                fatalError("Not used in this test")
            }
        }

        class SomeCoordinator: CoordinatorProtocol {
            var navigator: NavigatorProtocol = MockNavigator()
            func start() {}
        }

        let module = SomeModule()
        resolver.register(module)

        let resolved = resolver.resolve(SomeModule.self)
        XCTAssertNotNil(resolved)
    }

    func testDefaultModuleFactory() {
        let resolver = ModuleResolver()

        resolver.register(MockModule())

        let factory = DefaultModuleFactory(resolver: resolver)
        let navigator = MockNavigator()
        let coordinator = factory.makeCoordinator(for: MockModule.self, navigator: navigator)

        XCTAssertNotNil(coordinator)
        XCTAssertTrue(coordinator is MockCoordinator)
    }
}
