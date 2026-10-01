import AppKit
import RadioBrowserAPI
import Storage
import SwiftData
import NeedleFoundation

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
