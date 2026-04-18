import WidgetKit
import SwiftUI

@main
struct KlyxWidgetBundle: WidgetBundle {
    init() {

        if let urls = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil) {
            for url in urls {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        } else if let urls = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: "Fonts") {
            for url in urls {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        }
    }

    var body: some Widget {
        StreakWidget()
        HeatmapWidget()
        LCHeatmapWidget()
        WeeklyWidget()
    }
}
