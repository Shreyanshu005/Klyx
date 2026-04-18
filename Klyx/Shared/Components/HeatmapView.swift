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
    private let weeksToShow = 26

    /// Generate the grid of days for the past N weeks.
    private var gridDays: [[DayData]] {
        let calendar = Calendar.current
        let today = Date.now.startOfDay
        var weeks: [[DayData]] = []
        var currentWeek: [DayData] = []

        for dayOffset in stride(from: -(weeksToShow * 7 - 1), through: 0, by: 1) {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let key = date.isoDateString
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
            case 0: return Color.black
            case 1...3: return AppColors.boxGreen.opacity(0.3)
            case 4...6: return AppColors.boxGreen.opacity(0.6)
            case 7...9: return AppColors.boxGreen.opacity(0.8)
            default: return AppColors.boxGreen
            }
        case .leetcode:
            switch count {
            case 0: return Color.black
            case 1: return AppColors.boxYellow.opacity(0.3)
            case 2...3: return AppColors.boxYellow.opacity(0.6)
            case 4...5: return AppColors.boxYellow.opacity(0.8)
            default: return AppColors.boxYellow
            }
        }
    }

    private struct DayData {
        let date: Date
        let count: Int
    }
}
