import SwiftUI
import SwiftData

@main
struct KlyxApp: App {
    /// Shared SwiftData model container with App Group for widget access.
    let modelContainer: ModelContainer

    init() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil) {
            for url in urls {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        } else {
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
