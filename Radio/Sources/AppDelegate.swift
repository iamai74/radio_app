//
//  AppDelegate.swift
//  Radio
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
import RadioBrowserAPI
import Storage
import SwiftData
import NeedleFoundation
#endif

#if os(iOS)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingScene/session.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var appComponent: AppComponent?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Task { @MainActor in
            do {
                let dependency = try await AppInitializer.initialize()
                appComponent = AppComponent(appDependency: dependency)
                
                // Note: registerProviderFactories() should be implemented if needed
                
                let stationsService = appComponent!.stationsService
                print("StationsService initialized: \(stationsService)")
            } catch {
                print("Failed to initialize app: \(error)")
            }
        }

        window = NSWindow(
            contentRect: NSMakeRect(0, 0, 800, 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window?.title = "Radio"
        window?.center()
        
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
        window?.contentView = view
        
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
#endif
