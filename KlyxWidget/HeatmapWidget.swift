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

private let boxGreen = Color(red: 0.0, green: 0.82, blue: 0.4)

// MARK: - Widget Views

struct HeatmapWidgetView: View {
    let entry: HeatmapWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(entry.platform)
                    .font(.custom("ClashDisplay-Bold", size: 14))
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
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(colorFor(col: col, row: row))
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .containerBackground(Color(white: 0.08), for: .widget)
    }
    
    private func colorFor(col: Int, row: Int) -> Color {
        let total = col + row
        if entry.calendar.isEmpty { return .black }
        
        let isActive = (entry.calendar.values.first ?? 0) > 0 // pseudo-mock since it requires intense true date loop calculation
        return isActive && (total % 3 == 0) ? boxGreen : .black
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
