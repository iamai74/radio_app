//
//  SceneDelegate.swift
//  Radio
//

import Foundation
import UIKit
import Architecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appComponent: AppComponent?
    private var launchCoordinator: LaunchCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let navigator = IOSNavigator(window: window)

        Task { @MainActor in
            do {
                let dependency = try await AppInitializer.initialize()
                let appComponent = AppComponent(appDependency: dependency, navigator: navigator)
                self.appComponent = appComponent

                let coordinator = appComponent.launchComponent.coordinator
                self.launchCoordinator = coordinator
                coordinator.start()
            } catch {
                print("Failed to initialize app: \(error)")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
