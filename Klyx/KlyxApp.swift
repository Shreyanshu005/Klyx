//
//  KlyxApp.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import SwiftData

@main
struct KlyxApp: App {
    /// Shared SwiftData model container with App Group for widget access.
    let modelContainer: ModelContainer

    init() {
        // Register ALL custom .otf fonts dynamically bypassing Info.plist / .xcassets compile limits
        if let urls = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil) {
            for url in urls {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        } else {
            // Fallback for nested directories in newer Xcode project formats
            if let urls = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: "Fonts") {
                for url in urls {
                    var error: Unmanaged<CFError>?
                    CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
                }
            }
        }

        do {
            modelContainer = try DataStoreConfig.makeContainer()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
