//
//  AppDelegate.swift
//  Radio
//

import Foundation
import UIKit
import NeedleFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var appComponent: AppComponent?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerProviderFactories()

        Task { @MainActor in
            do {
                let dependency = try await AppInitializer.initialize()
                appComponent = AppComponent(appDependency: dependency)
            } catch {
                print("Failed to initialize app: \(error)")
            }
        }
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
