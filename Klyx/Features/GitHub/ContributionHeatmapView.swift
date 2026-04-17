//
//  ContributionHeatmapView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// GitHub-style contribution heatmap showing the past year of activity.
struct ContributionHeatmapView: View {
    let calendar: GHContributionCalendar

    private let cellSize: CGFloat = 12
    private let cellSpacing: CGFloat = 3
    private let dayLabels = ["", "Mon", "", "Wed", "", "Fri", ""]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contributions")
                .font(.headline)

            Text("\(calendar.totalContributions) contributions in the last year")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: cellSpacing) {
                    // Day labels column
                    VStack(spacing: cellSpacing) {
                        ForEach(dayLabels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                                .frame(width: 24, height: cellSize)
                        }
                    }

                    // Weeks
                    ForEach(Array(calendar.weeks.enumerated()), id: \.offset) { _, week in
                        VStack(spacing: cellSpacing) {
                            ForEach(week.contributionDays) { day in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: day.color))
                                    .frame(width: cellSize, height: cellSize)
                                    .help("\(day.date): \(day.contributionCount) contributions")
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 4) {
                Spacer()
                Text("Less")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)

                ForEach(["#ebedf0", "#9be9a8", "#40c463", "#30a14e", "#216e39"], id: \.self) { hex in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: hex))
                        .frame(width: 10, height: 10)
                }

                Text("More")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
