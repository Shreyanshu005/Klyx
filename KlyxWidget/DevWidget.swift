//
//  DevWidget.swift
//  KlyxWidget
//
//  Created by Shreyanshu on 17/04/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct DevWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DevWidgetEntry {
        DevWidgetEntry(date: .now, score: 742, tier: "Expert", lcSolved: 120, ghContribs: 480, cfRating: 1400, streak: 12)
    }

    func getSnapshot(in context: Context, completion: @escaping (DevWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DevWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func loadEntry() -> DevWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.shreyanshu.klyx") ?? .standard

        if let data = defaults.data(forKey: "cached_dev_score"),
           let score = try? JSONDecoder().decode(WidgetDevScore.self, from: data) {
            return DevWidgetEntry(
                date: .now,
                score: score.compositeScore,
                tier: score.tier,
                lcSolved: score.lcTotalSolved,
                ghContribs: score.ghTotalContributions,
                cfRating: score.cfRating,
                streak: score.ghCurrentStreak
            )
        }

        return DevWidgetEntry(date: .now, score: 0, tier: "Beginner", lcSolved: 0, ghContribs: 0, cfRating: nil, streak: 0)
    }
}

// MARK: - Lightweight DevScore for Widget Decoding

/// Minimal Codable mirror of DevScore — avoids importing the full main app.
private struct WidgetDevScore: Codable {
    let lcTotalSolved: Int
    let ghTotalContributions: Int
    let ghCurrentStreak: Int
    let cfRating: Int?

    var compositeScore: Int {
        var s: Double = 0
        s += min(Double(lcTotalSolved) / 500.0, 1.0) * 350
        s += min(Double(ghTotalContributions) / 2000.0, 1.0) * 350
        s += min(Double(cfRating ?? 0) / 2400.0, 1.0) * 300
        return min(Int(s), 1000)
    }

    var tier: String {
        switch compositeScore {
        case 0..<200:    return "Beginner"
        case 200..<400:  return "Intermediate"
        case 400..<600:  return "Advanced"
        case 600..<800:  return "Expert"
        case 800...1000: return "Legendary"
        default:         return "Unknown"
        }
    }
}

// MARK: - Entry

struct DevWidgetEntry: TimelineEntry {
    let date: Date
    let score: Int
    let tier: String
    let lcSolved: Int
    let ghContribs: Int
    let cfRating: Int?
    let streak: Int
}

// MARK: - Box Box Flat Colors for Widget
private let pureBlack = Color(red: 0, green: 0, blue: 0)
private let boxRed = Color(red: 1.0, green: 0.13, blue: 0.13)
private let boxYellow = Color(red: 0.88, green: 1.0, blue: 0.0)
private let boxGreen = Color(red: 0.0, green: 0.82, blue: 0.4)

// MARK: - Small Widget View

struct DevWidgetSmallView: View {
    let entry: DevWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SCORE")
                .font(.custom("ClashDisplay-Bold", size: 10))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1)
            
            Text("\(entry.score)")
                .font(.custom("ClashDisplay-Bold", size: 54))
                .foregroundStyle(boxGreen)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .tracking(-2)

            Spacer()

            Text(entry.tier.uppercased())
                .font(.custom("ClashDisplay-Bold", size: 14))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                Label("\(entry.lcSolved)", systemImage: "chevron.left.forwardslash.chevron.right")
                Label("\(entry.streak)", systemImage: "flame.fill")
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(4)
        .containerBackground(Color(white: 0.08), for: .widget) // Dark gray card background
    }
}

// MARK: - Medium Widget View

struct DevWidgetMediumView: View {
    let entry: DevWidgetEntry

    var body: some View {
        HStack(spacing: 20) {
            // Main Score Area
            VStack(alignment: .leading, spacing: 0) {
                Text("DEV SCORE")
                    .font(.custom("ClashDisplay-Bold", size: 12))
                    .foregroundStyle(.black.opacity(0.6))
                    .tracking(1)
                
                Text("\(entry.score)")
                    .font(.custom("ClashDisplay-Bold", size: 72))
                    .foregroundStyle(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .tracking(-3)
                
                Text(entry.tier.uppercased())
                    .font(.custom("ClashDisplay-Bold", size: 16))
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right side stats
            VStack(alignment: .leading, spacing: 8) {
                statsRow(icon: "chevron.left.forwardslash.chevron.right", val: "\(entry.lcSolved)")
                statsRow(icon: "arrow.triangle.branch", val: "\(entry.ghContribs)")
                statsRow(icon: "flame.fill", val: "\(entry.streak) DAYS")
            }
        }
        .padding(8)
        .containerBackground(boxYellow, for: .widget)
    }
    
    private func statsRow(icon: String, val: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 16)
            Text(val.uppercased())
                .font(.custom("ClashDisplay-Bold", size: 16))
                .foregroundStyle(.black)
        }
    }
}

// MARK: - Widget Definition

struct DevWidget: Widget {
    let kind = "DevWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DevWidgetProvider()) { entry in
            DevWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Dev Score")
        .description("Your unified developer score at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DevWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DevWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            DevWidgetSmallView(entry: entry)
        case .systemMedium:
            DevWidgetMediumView(entry: entry)
        default:
            DevWidgetSmallView(entry: entry)
        }
    }
}
