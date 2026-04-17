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
    var body: some Widget {
        DevWidget()
        StreakWidget()
        HeatmapWidget()
        LCHeatmapWidget()
    }
}
