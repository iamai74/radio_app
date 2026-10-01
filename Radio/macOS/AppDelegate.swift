//
//  AppDelegate.swift
//  RadioM
//
//  Created by iamai on 20.02.2026.
//

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
            let modelContainer = try! StorageContainer.create()
            let storageDi = Storage.DIContainer.shared
            storageDi.register(modelContainer: modelContainer)
            
            let networkClient = DefaultNetworkClient()
            let dataStore = storageDi.dataStore
            
            let dependency = AppDependencyImpl(
                networkClient: networkClient,
                dataStore: dataStore
            )
            appComponent = AppComponent(appDependency: dependency)
            
            registerProviderFactories()
            
            let stationsService = appComponent!.stationsService
            print("StationsService initialized: \(stationsService)")
        }

        window = NSWindow(
            contentRect: NSMakeRect(0, 0, 800, 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window?.title = "RadioM"
        window?.center()
        
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
        window?.contentView = view
        
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

@MainActor
final class AppDependencyImpl: AppDependency {
    let networkClient: NetworkClientProtocol
    let dataStore: Storage.DataStore
    
    init(networkClient: NetworkClientProtocol, dataStore: Storage.DataStore) {
        self.networkClient = networkClient
        self.dataStore = dataStore
    }
}
