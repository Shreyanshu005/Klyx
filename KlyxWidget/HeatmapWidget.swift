//
//  HeatmapWidget.swift
//  KlyxWidget
//
//  Created by Shreyanshu on 17/04/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct HeatmapWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HeatmapWidgetEntry {
        HeatmapWidgetEntry(date: .now, platform: "GITHUB", calendar: ["2026-04-17": 5, "2026-04-16": 2])
    }

    func getSnapshot(in context: Context, completion: @escaping (HeatmapWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeatmapWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
    
    private func loadEntry() -> HeatmapWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.shreyanshu.klyx") ?? .standard

        if let data = defaults.data(forKey: "cached_gh_profile"),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            return HeatmapWidgetEntry(date: .now, platform: "GITHUB", calendar: dict)
        }

        return HeatmapWidgetEntry(date: .now, platform: "GITHUB", calendar: [:])
    }
}

// MARK: - Entry

struct HeatmapWidgetEntry: TimelineEntry {
    let date: Date
    let platform: String
    let calendar: [String: Int]
}

private let boxGreen = Color(red: 2/255.0, green: 187/255.0, blue: 129/255.0)

// MARK: - Widget Views

struct HeatmapWidgetView: View {
    let entry: HeatmapWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(entry.platform)
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white)
                    .tracking(1)
                Spacer()
                Image(systemName: "arrow.triangle.branch")
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 12)

            // Dynamic grid parsing real gh cache
            HStack(spacing: 4) {
                ForEach(0..<18) { col in
                    VStack(spacing: 4) {
                        ForEach(0..<4) { row in
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.black.opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(colorFor(col: col, row: row))
                            }
                            .frame(width: 14, height: 14)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .containerBackground(AppColors.boxGreen, for: .widget)
    }
    
    private func colorFor(col: Int, row: Int) -> Color {
        let maxCols = 18
        let maxRows = 4
        let daysAgo = ((maxCols - 1) - col) * maxRows + ((maxRows - 1) - row)
        
        guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: entry.date) else {
            return .clear
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let count = entry.calendar[dateString] ?? 0
        if count == 0 { return .clear }
        
        // Deep obsidian green for contrast on bright background
        let obsidianGreen = Color(red: 0/255.0, green: 80/255.0, blue: 40/255.0)
        
        if count < 3 { return obsidianGreen.opacity(0.3) }
        if count < 10 { return obsidianGreen.opacity(0.6) }
        return obsidianGreen.opacity(0.9)
    }
}

// MARK: - Widget Definition

struct HeatmapWidget: Widget {
    let kind = "HeatmapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeatmapWidgetProvider()) { entry in
            HeatmapWidgetView(entry: entry)
        }
        .configurationDisplayName("Heatmap")
        .description("Your activity heatmap right on the home screen.")
        .supportedFamilies([.systemMedium]) // Medium fits the grid best
    }
}
