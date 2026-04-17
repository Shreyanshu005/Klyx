//
//  LCHeatmapWidget.swift
//  KlyxWidget
//
//  Created by Shreyanshu on 17/04/26.
//

import WidgetKit
import SwiftUI

// MARK: - LCProvider

struct LCHeatmapWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LCHeatmapWidgetEntry {
        LCHeatmapWidgetEntry(date: .now, calendar: ["2026-04-17": 5, "2026-04-16": 2])
    }

    func getSnapshot(in context: Context, completion: @escaping (LCHeatmapWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LCHeatmapWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func loadEntry() -> LCHeatmapWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.shreyanshu.klyx") ?? .standard

        if let data = defaults.data(forKey: "cached_lc_profile"),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            return LCHeatmapWidgetEntry(date: .now, calendar: dict)
        }

        return LCHeatmapWidgetEntry(date: .now, calendar: [:])
    }
}

// MARK: - Entry

struct LCHeatmapWidgetEntry: TimelineEntry {
    let date: Date
    let calendar: [String: Int]
}

// MARK: - Widget View

struct LCHeatmapWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LCHeatmapWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("LEETCODE")
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white)
                    .tracking(1)
                Spacer()
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundStyle(.white)
            }
            Spacer()
            
            WidgetLCGrid(data: entry.calendar, anchor: entry.date)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(family == .systemSmall ? 12 : 16) // Reduced padding for small
        .containerBackground(AppColors.pureBlack, for: .widget)
    }
}

// MARK: - Helper Grid

struct WidgetLCGrid: View {
    @Environment(\.widgetFamily) var family
    let data: [String: Int]
    let anchor: Date
    
    private var gridConfig: (cols: Int, size: CGFloat, spacing: CGFloat) {
        switch family {
        case .systemSmall:
            return (cols: 6, size: 14, spacing: 3)
        default:
            return (cols: 15, size: 10, spacing: 3)
        }
    }
    
    var body: some View {
        let config = gridConfig
        HStack(spacing: config.spacing) {
            ForEach(0..<config.cols, id: \.self) { col in
                VStack(spacing: config.spacing) {
                    ForEach(0..<7, id: \.self) { row in
                        ZStack {
                            // Slot background so it doesn't look "empty"
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.black.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(colorFor(col: col, row: row, maxCols: config.cols))
                        }
                        .frame(width: config.size, height: config.size)
                    }
                }
            }
        }
    }
    
    private func colorFor(col: Int, row: Int, maxCols: Int) -> Color {
        let maxRows = 7
        let daysAgo = ((maxCols - 1) - col) * maxRows + ((maxRows - 1) - row)
        
        guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: anchor) else {
            return .clear
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let count = data[dateString] ?? 0
        if count == 0 { return .clear }
        
        // Deep Obsidian/Emerald colors for LeetCode on Yellow
        let leaf = Color(red: 25/255.0, green: 150/255.0, blue: 60/255.0)
        
        if count < 2 { return leaf.opacity(0.3) }
        if count < 5 { return leaf.opacity(0.6) }
        if count < 10 { return leaf.opacity(0.8) }
        return leaf
    }
}

// MARK: - Widget Definition

struct LCHeatmapWidget: Widget {
    let kind: String = "LCHeatmapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LCHeatmapWidgetProvider()) { entry in
            LCHeatmapWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("LC Heatmap")
        .description("Track your daily LeetCode activity.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
