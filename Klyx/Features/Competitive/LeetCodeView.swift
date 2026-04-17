//
//  LeetCodeView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// Detailed LeetCode stats — Box Box flat aesthetic with Clash Display.
struct LeetCodeView: View {
    let viewModel: CompetitiveViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // MARK: - Hero Header
                HStack {
                    Text("LEETCODE")
                        .clash(size: 38, weight: .bold)
                        .foregroundStyle(.white)
                        .tracking(2)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
                
                // MARK: - Profile Header
                if let profile = viewModel.lcProfile {
                    profileHeader(profile)
                }

                // MARK: - Ranked Section & Contest
                if let contest = viewModel.lcContestData?.userContestRanking {
                    contestSection(contest)
                }

                // MARK: - Problem Breakdown
                if let stats = viewModel.lcProfile?.submitStatsGlobal {
                    problemBreakdown(stats)
                }

                // MARK: - Submission Heatmap
                if !viewModel.lcCalendar.isEmpty {
                    BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SUBMISSIONS")
                                .clash(size: 18, weight: .bold)
                                .foregroundStyle(AppColors.boxYellow)
                                .tracking(1)
                            HeatmapView(
                                data: viewModel.lcCalendar,
                                platform: .leetcode
                            )
                        }
                    }
                }

                // MARK: - Recent Submissions
                if !viewModel.lcSubmissions.isEmpty {
                    recentSubmissions
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppColors.pureBlack.ignoresSafeArea())
    }

    // MARK: - Subviews

    private func profileHeader(_ profile: LCMatchedUser) -> some View {
        BentoCard(backgroundColor: AppColors.boxYellow, cornerRadius: 36) {
            HStack(spacing: 16) {
                if let avatar = profile.profile.userAvatar, let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(AppColors.pureBlack.opacity(0.1))
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.black, lineWidth: 4))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.username.uppercased())
                        .clash(size: 28, weight: .bold)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    if let name = profile.profile.realName, !name.isEmpty {
                        Text(name.uppercased())
                            .clash(size: 14, weight: .bold)
                            .foregroundStyle(.black.opacity(0.7))
                    }

                    if let ranking = profile.profile.ranking {
                        Text("RANK #\(ranking)")
                            .clash(size: 14, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.pureBlack, in: Capsule())
                            .padding(.top, 4)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(height: 140)
    }

    private func contestSection(_ contest: LCContestRanking) -> some View {
        HStack(spacing: 12) {
            StatCard(
                title: "CONTEST",
                value: String(format: "%.0f", contest.rating),
                subtitle: "RATING",
                icon: "chart.line.uptrend.xyaxis",
                color: AppColors.boxBlue
            )

            StatCard(
                title: "GLOBAL",
                value: "#\(contest.globalRanking)",
                subtitle: "RANK",
                icon: "globe",
                color: AppColors.boxRed
            )
        }
        .frame(height: 180)
    }

    private func problemBreakdown(_ stats: LCSubmitStats) -> some View {
        BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 24) {
                Text("SOLVED")
                    .clash(size: 18, weight: .bold)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(1)

                HStack(spacing: 8) {
                    ForEach(stats.acSubmissionNum, id: \.difficulty) { stat in
                        if stat.difficulty != "All" {
                            VStack(spacing: 8) {
                                Text("\(stat.count)")
                                    .clash(size: 42, weight: .bold)
                                    .foregroundStyle(colorForDifficulty(stat.difficulty))
                                
                                Text(stat.difficulty.uppercased())
                                    .clash(size: 12, weight: .bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(colorForDifficulty(stat.difficulty).opacity(0.3), in: Capsule())
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var recentSubmissions: some View {
        BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 24) {
                Text("RECENT SOLVES")
                    .clash(size: 18, weight: .bold)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(1)

                ForEach(Array(viewModel.lcSubmissions.prefix(8).enumerated()), id: \.element.id) { index, submission in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(submission.title)
                                .clash(size: 20, weight: .bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(submission.lang.uppercased())
                                .clash(size: 10, weight: .bold)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.boxYellow, in: Capsule())
                        }

                        Spacer()

                        if let date = submission.date {
                            Text(date.timeAgo.uppercased())
                                .clash(size: 12, weight: .bold)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    if index < min(viewModel.lcSubmissions.count, 8) - 1 {
                        Divider().background(.white.opacity(0.1))
                            .padding(.vertical, 6)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Helpers

    private func colorForDifficulty(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return AppColors.boxGreen
        case "Medium": return AppColors.boxYellow
        case "Hard": return AppColors.boxRed
        default: return .gray
        }
    }
}
