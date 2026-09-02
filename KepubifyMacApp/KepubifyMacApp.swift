//
//  KepubifyMacApp.swift
//  KepubifyMacApp
//
//  Created by Vibe Code
//

import SwiftUI
import AppKit

@main
struct KepubifyMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
        
        WindowGroup {
            ContentView()
                .environmentObject(KepubifyManager())
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app works properly
        NSApp.activationPolicy = .regular
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
