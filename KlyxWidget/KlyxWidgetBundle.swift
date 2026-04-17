//
//  KlyxWidgetBundle.swift
//  KlyxWidget
//
//  Created by Shreyanshu on 17/04/26.
//

import WidgetKit
import SwiftUI

@main
struct KlyxWidgetBundle: WidgetBundle {
    init() {
        // Explicitly register brutalist fonts specifically for the Widget Sandbox environment natively
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
