//
//  CodeforcesView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// Codeforces stats — Box Box flat aesthetic with Clash Display.
struct CodeforcesView: View {
    let viewModel: CompetitiveViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // MARK: - Hero Header
                HStack {
                    Text("CODEFORCES")
                        .clash(size: 38, weight: .bold)
                        .foregroundStyle(.white)
                        .tracking(2)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
                
                // MARK: - Profile Header
                if let user = viewModel.cfUser {
                    profileHeader(user)
                }

                // MARK: - Ratings & Contests
                if let user = viewModel.cfUser {
                    ratingCards(user)
                }

                // MARK: - Upcoming Contests
                if !viewModel.cfUpcomingContests.isEmpty {
                    upcomingContestsSection
                }

                // MARK: - Recent Submissions
                if !viewModel.cfSubmissions.isEmpty {
                    recentSubmissions
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppColors.pureBlack.ignoresSafeArea())
    }

    // MARK: - Subviews

    private func profileHeader(_ user: CFUser) -> some View {
        BentoCard(backgroundColor: AppColors.boxBlue, cornerRadius: 36) {
            HStack(spacing: 16) {
                if let avatar = user.avatar, let url = URL(string: avatar) {
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
                    Text(user.handle.uppercased())
                        .clash(size: 28, weight: .bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    if let rank = user.rank {
                        RankBadge(rank: rank, platform: .codeforces)
                            .padding(.top, 4)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(height: 140)
    }

    private func ratingCards(_ user: CFUser) -> some View {
        HStack(spacing: 12) {
            StatCard(
                title: "CURRENT",
                value: "\(user.rating ?? 0)",
                subtitle: "RATING",
                icon: "chart.line.uptrend.xyaxis",
                color: AppColors.boxGreen
            )

            StatCard(
                title: "PEAK",
                value: "\(user.maxRating ?? 0)",
                subtitle: "RATING",
                icon: "crown.fill",
                color: AppColors.boxYellow
            )
            
            StatCard(
                title: "CONTESTS",
                value: "\(viewModel.cfRatingHistory.count)",
                subtitle: "PLAYED",
                icon: "trophy.fill",
                color: AppColors.boxRed
            )
        }
        .frame(height: 180)
    }

    private var recentSubmissions: some View {
        BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 24) {
                Text("RECENT SOLVES")
                    .clash(size: 18, weight: .bold)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(1)

                ForEach(Array(viewModel.cfSubmissions.prefix(8).enumerated()), id: \.element.id) { index, sub in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sub.problem.name.uppercased())
                                .clash(size: 18, weight: .bold)
                                .foregroundStyle(sub.isAccepted ? AppColors.boxGreen : AppColors.boxRed)
                                .lineLimit(1)

                            HStack(spacing: 6) {
                                Text(sub.programmingLanguage.uppercased())
                                    .clash(size: 10, weight: .bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.boxBlue, in: Capsule())

                                if let rating = sub.problem.rating {
                                    Text("\(rating)")
                                        .clash(size: 10, weight: .bold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.white, in: Capsule())
                                }
                            }
                        }

                        Spacer()

                        Text(sub.date.timeAgo.uppercased())
                            .clash(size: 12, weight: .bold)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    if index < min(viewModel.cfSubmissions.count, 8) - 1 {
                        Divider().background(.white.opacity(0.1))
                            .padding(.vertical, 6)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var upcomingContestsSection: some View {
        BentoCard(backgroundColor: AppColors.boxBlue, cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("UPCOMING CONTESTS")
                        .clash(size: 18, weight: .bold)
                        .foregroundStyle(.white)
                        .tracking(1)
                    Spacer()
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.white)
                }

                ForEach(Array(viewModel.cfUpcomingContests.prefix(3).enumerated()), id: \.element.id) { index, contest in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contest.name.uppercased())
                                .clash(size: 14, weight: .bold)
                                .foregroundStyle(.white)
                                .lineLimit(2)

                            if let date = contest.startDate {
                                Text(date.formatted(date: .abbreviated, time: .shortened).uppercased())
                                    .clash(size: 10, weight: .bold)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.white, in: Capsule())
                            }
                        }
                        Spacer()
                    }

                    if index < min(viewModel.cfUpcomingContests.count, 3) - 1 {
                        Divider().background(.white.opacity(0.2))
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
