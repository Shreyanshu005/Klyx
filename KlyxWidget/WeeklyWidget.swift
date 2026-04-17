//
//  WeeklyWidget.swift
//  KlyxWidget
//
//  Created by Shreyanshu on 17/04/26.
//

import WidgetKit
import SwiftUI

struct WeeklyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklyWidgetEntry {
        WeeklyWidgetEntry(date: .now, calendar: ["2026-04-17": 1], title: "LEETCODE WEEKLY")
    }

    func getSnapshot(in context: Context, completion: @escaping (WeeklyWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func loadEntry() -> WeeklyWidgetEntry {
        let defaults = UserDefaults(suiteName: Constants.appGroupID) ?? .standard
        let lcData = defaults.data(forKey: "cached_lc_profile")
        let dict = (try? JSONDecoder().decode([String: Int].self, from: lcData ?? Data())) ?? [:]
        
        return WeeklyWidgetEntry(date: .now, calendar: dict, title: "LEETCODE WEEKLY")
    }
}

struct WeeklyWidgetEntry: TimelineEntry {
    let date: Date
    let calendar: [String: Int]
    let title: String
}

struct WeeklyWidgetView: View {
    var entry: WeeklyWidgetEntry
    @Environment(\.widgetFamily) var family

    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    private let brandYellow = Color(red: 255/255.0, green: 218/255.0, blue: 39/255.0)

    private var weeklyData: [(day: String, count: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let anchor = entry.date
        
        // Find the start of the current week (Sunday)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: anchor)
        guard let startOfWeek = calendar.date(from: components) else { return [] }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            let dayIndex = calendar.component(.weekday, from: date) - 1
            let key = formatter.string(from: date)
            let count = entry.calendar[key] ?? 0
            let isToday = calendar.isDate(date, inSameDayAs: anchor)
            
            return (day: days[dayIndex], count: count, isToday: isToday)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.title)
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white)
                Spacer()
                let activeCount = weeklyData.filter { $0.count > 0 }.count
                Text("\(activeCount)/7")
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white.opacity(0.8))
            }

            HStack(spacing: family == .systemSmall ? 4 : 8) {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.white)
                                .opacity(day.count > 0 ? 1.0 : 0.0)
                        }
                        .frame(height: family == .systemSmall ? 32 : 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(day.isToday ? 0.3 : 0), lineWidth: 1)
                        )
                        
                        Text(day.day)
                            .clash(size: 10, weight: .bold)
                            .foregroundStyle(day.isToday ? .white : .white.opacity(0.4))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer(minLength: 0)
            
            Text("7-Day Progress Tracking")
                .clash(size: 10, weight: .bold)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(16)
        .containerBackground(AppColors.boxBlue, for: .widget)
    }
}

struct WeeklyWidget: Widget {
    let kind: String = "WeeklyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeeklyWidgetProvider()) { entry in
            WeeklyWidgetView(entry: entry)
        }
        .configurationDisplayName("7-Day Progress")
        .description("Track your current week's activity streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Date Helpers (Local copy for widget target if needed, but assuming shared extensions)
// Assuming Date+Helpers.swift is included in the Widget target.
