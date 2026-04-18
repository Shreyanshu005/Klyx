import SwiftUI

/// GitHub-style contribution heatmap showing the past year of activity.
struct ContributionHeatmapView: View {
    let calendar: GHContributionCalendar

    private let cellSize: CGFloat = 12
    private let cellSpacing: CGFloat = 3
    private let dayLabels = ["", "Mon", "", "Wed", "", "Fri", ""]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: cellSpacing) {

                    ForEach(Array(calendar.weeks.enumerated()), id: \.offset) { _, week in
                        VStack(spacing: cellSpacing) {
                            ForEach(week.contributionDays) { day in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(colorFor(day.contributionCount))
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }

            HStack {
                Text("\(calendar.totalContributions) CONTRIBUTIONS")
                    .clash(size: 10, weight: .bold)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()

                HStack(spacing: 4) {
                    ForEach([0.1, 0.4, 0.7, 1.0], id: \.self) { opacity in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.boxGreen.opacity(opacity))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
    }

    private func colorFor(_ count: Int) -> Color {
        if count == 0 { return Color.black }
        if count < 3 { return AppColors.boxGreen.opacity(0.3) }
        if count < 6 { return AppColors.boxGreen.opacity(0.6) }
        if count < 9 { return AppColors.boxGreen.opacity(0.8) }
        return AppColors.boxGreen
    }
}
