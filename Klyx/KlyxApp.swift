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
        do {
            modelContainer = try DataStoreConfig.makeContainer()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(modelContainer)
    }

    /// Reads the user's appearance preference.
    private var colorScheme: ColorScheme? {
        let raw = UserDefaults.standard.string(forKey: "appearance") ?? "system"
        switch raw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
