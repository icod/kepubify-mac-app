//
//  KepubifyMacApp.swift
//  KepubifyMacApp
//
//  Created by Vibe Code
//

import SwiftUI

@main
struct KepubifyMacApp: App {
    @StateObject private var kepubifyManager = KepubifyManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(kepubifyManager)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
    }
}
