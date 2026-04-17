//
//  HeatmapView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// Reusable heatmap grid — works for both GitHub contributions and LeetCode submissions.
/// Takes a dictionary of `[unixTimestamp/dateString: count]`.
struct HeatmapView: View {
    let data: [String: Int]
    let platform: Platform

    enum Platform {
        case github, leetcode
    }

    private let cellSize: CGFloat = 11
    private let spacing: CGFloat = 2
    private let weeksToShow = 26  // ~6 months

    /// Generate the grid of days for the past N weeks.
    private var gridDays: [[DayData]] {
        let calendar = Calendar.current
        let today = Date.now.startOfDay
        var weeks: [[DayData]] = []
        var currentWeek: [DayData] = []

        for dayOffset in stride(from: -(weeksToShow * 7 - 1), through: 0, by: 1) {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let key = date.isoDateString // Both platforms now use yyyy-MM-dd
            let count = data[key] ?? 0
            currentWeek.append(DayData(date: date, count: count))

            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }

        if !currentWeek.isEmpty {
            weeks.append(currentWeek)
        }

        return weeks
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(Array(gridDays.enumerated()), id: \.offset) { _, week in
                    VStack(spacing: spacing) {
                        ForEach(week, id: \.date) { day in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(colorForCount(day.count))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    private func colorForCount(_ count: Int) -> Color {
        switch platform {
        case .github:
            switch count {
            case 0: return Color(hex: "#161b22")
            case 1...3: return Color(hex: "#0e4429")
            case 4...6: return Color(hex: "#006d32")
            case 7...9: return Color(hex: "#26a641")
            default: return Color(hex: "#39d353")
            }
        case .leetcode:
            switch count {
            case 0: return Color(hex: "#2a2a2a")
            case 1: return Color(hex: "#5a3e00")
            case 2...3: return Color(hex: "#8a5c00")
            case 4...5: return Color(hex: "#c78400")
            default: return Color(hex: "#ffa116")
            }
        }
    }

    private struct DayData {
        let date: Date
        let count: Int
    }
}
