//
//  StreakWidget.swift
//  KlyxWidget
//
//  Created by Shreyanshu on 17/04/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct StreakWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakWidgetEntry {
        StreakWidgetEntry(date: .now, ghStreak: 12, lcStreak: 5, longestStreak: 48)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func loadEntry() -> StreakWidgetEntry {
        let defaults = UserDefaults(suiteName: Constants.appGroupID) ?? .standard

        if let data = defaults.data(forKey: "cached_aggregated_stats"),
           let score = try? JSONDecoder().decode(WidgetStreakData.self, from: data) {
            return StreakWidgetEntry(
                date: .now,
                ghStreak: score.ghCurrentStreak,
                lcStreak: score.lcStreak,
                longestStreak: score.ghLongestStreak
            )
        }

        return StreakWidgetEntry(date: .now, ghStreak: 0, lcStreak: 0, longestStreak: 0)
    }
}

/// Minimal Codable mirror for reading streak data from cached DevScore.
private struct WidgetStreakData: Codable {
    let ghCurrentStreak: Int
    let ghLongestStreak: Int
    let lcStreak: Int
}

// MARK: - Entry

struct StreakWidgetEntry: TimelineEntry {
    let date: Date
    let ghStreak: Int
    let lcStreak: Int
    let longestStreak: Int
}

private let boxRed = Color(red: 245/255.0, green: 25/255.0, blue: 29/255.0)

// MARK: - Small Widget View

struct StreakWidgetSmallView: View {
    let entry: StreakWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("STREAK")
                .clash(size: 10, weight: .bold)
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1)
            
            Text("\(max(entry.ghStreak, entry.lcStreak))")
                .clash(size: 54, weight: .bold)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .tracking(-3)

            Text("DAY STREAK")
                .clash(size: 12, weight: .bold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .containerBackground(AppColors.boxRed, for: .widget)
    }
}

// MARK: - Medium Widget View

struct StreakWidgetMediumView: View {
    let entry: StreakWidgetEntry

    var body: some View {
        HStack(spacing: 20) {
            // Main Top Streak
            VStack(alignment: .leading, spacing: 0) {
                Text("HOT STREAK")
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(1)
                
                Text("\(max(entry.ghStreak, entry.lcStreak))")
                    .clash(size: 64, weight: .bold)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .tracking(-3)
                
                Text("DAYS")
                    .clash(size: 16, weight: .bold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 8) {
                statsRow(label: "GITHUB", val: "\(entry.ghStreak)")
                statsRow(label: "LEETCODE", val: "\(entry.lcStreak)")
                statsRow(label: "LONGEST", val: "\(entry.longestStreak)")
            }
        }
        .padding(16)
        .containerBackground(AppColors.boxRed, for: .widget)
    }

    private func statsRow(label: String, val: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .clash(size: 12, weight: .bold)
                .foregroundStyle(.white.opacity(0.8))
            Text(val)
                .clash(size: 18, weight: .bold)
                .foregroundStyle(.white)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Widget Definition

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakWidgetProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Coding Streak")
        .description("Track your daily coding streaks across platforms.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StreakWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: StreakWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            StreakWidgetSmallView(entry: entry)
        case .systemMedium:
            StreakWidgetMediumView(entry: entry)
        default:
            StreakWidgetSmallView(entry: entry)
        }
    }
}
