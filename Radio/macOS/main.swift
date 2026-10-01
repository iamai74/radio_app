//
//  main.swift
//  Radio
//
//  Created by iamai on 21.02.2026.
//
import AppKit

// 1
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 2
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
