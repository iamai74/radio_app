//
//  AppDelegate.swift
//  Radio
//

import Foundation
import Cocoa
import RadioBrowserAPI
import Storage
import SwiftData
import NeedleFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var appComponent: AppComponent?
    private var launchCoordinator: LaunchCoordinator?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerProviderFactories()

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Radio"
        window.center()
        self.window = window

        let navigator = MacOSNavigator(window: window)

        Task { @MainActor in
            do {
                let dependency = try await AppInitializer.initialize()
                let appComponent = AppComponent(appDependency: dependency, navigator: navigator)
                self.appComponent = appComponent

                let stationsService = appComponent.stationsService
                print("StationsService initialized: \(stationsService)")

                let coordinator = appComponent.launchComponent.coordinator
                self.launchCoordinator = coordinator
                coordinator.start()
            } catch {
                print("Failed to initialize app: \(error)")
            }
        }

        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
