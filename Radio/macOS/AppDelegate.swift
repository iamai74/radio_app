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
