//
//  DashboardView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import SwiftData

/// The ultimate massive Box Box Dashboard featuring edge-to-edge bento graphics and Clash Display typography.
struct DashboardView: View {
    @Query private var profiles: [UserProfile]
    @State private var viewModel = DashboardViewModel()

    private var profile: UserProfile? { profiles.first }
    
    // Auto-triggering task state bound to profile keys
    private var fingerprint: String {
        return [profile?.githubUsername, profile?.leetcodeUsername, profile?.codeforcesHandle]
            .compactMap { $0 }
            .joined(separator: "|")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.pureBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // MARK: - Massive Header
                        HStack {
                            Text("DASHBOARD")
                                .clash(size: 38, weight: .bold)
                                .foregroundStyle(.white)
                                .tracking(2)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 4)

                        // MARK: - Status Readout
                        if viewModel.isLoading && profile != nil {
                            syncIndicator
                        } else if let error = viewModel.errorMessage {
                            errorCard(error)
                        }

                        // MARK: - Grid Layout
                        if profile != nil {
                            VStack(spacing: 12) {
                                // 1. Hero DevScore Card
                                scoreBento
                                
                                // 2. Platform Sub-Scores
                                HStack(spacing: 12) {
                                    platformBento(
                                        title: "GITHUB",
                                        score: "\(viewModel.devScore.ghTotalContributions)",
                                        sub: "CONTRIBS",
                                        color: AppColors.boxGreen,
                                        icon: "arrow.triangle.branch"
                                    )
                                    
                                    platformBento(
                                        title: "LEETCODE",
                                        score: "\(viewModel.devScore.lcTotalSolved)",
                                        sub: "SOLVED",
                                        color: AppColors.boxYellow,
                                        icon: "chevron.left.forwardslash.chevron.right"
                                    )
                                }
                                .frame(height: 160)

                                // 3. Codeforces Single Wide Bento
                                HStack {
                                    platformBento(
                                        title: "CODEFORCES",
                                        score: "\(viewModel.devScore.cfRating ?? 0)",
                                        sub: "RATING",
                                        color: AppColors.boxBlue,
                                        icon: "trophy.fill"
                                    )
                                    
                                    StatsBlock(
                                        streak: "\(viewModel.devScore.ghCurrentStreak)D",
                                        rank: viewModel.devScore.cfRank ?? "UNRATED"
                                    )
                                }
                                .frame(height: 160)
                            }
                        } else {
                            ContentUnavailableView(
                                "No Accounts Synced",
                                systemImage: "link.badge.plus",
                                description: Text("Go to Settings to add your developer accounts.")
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .task(id: fingerprint) {
                if let p = profile {
                    await sync(p)
                }
            }
            .refreshable {
                if let p = profile {
                    await sync(p)
                }
            }
        }
    }
    
    private func sync(_ p: UserProfile) async {
        let token = KeychainManager.shared.loadString(forKey: KeychainManager.Keys.githubToken)
        await viewModel.refresh(
            lcUsername: p.leetcodeUsername,
            ghUsername: p.githubUsername,
            ghToken: token,
            cfHandle: p.codeforcesHandle
        )
    }

    // MARK: - Components

    private var syncIndicator: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(AppColors.boxYellow)
            Text("SYNCING LIVE...")
                .clash(size: 14, weight: .bold)
                .foregroundStyle(.white.opacity(0.8))
                .tracking(1)
            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func errorCard(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColors.boxRed)
            Text(message.uppercased())
                .clash(size: 14, weight: .bold)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Massive Hero Banner for the Total DevScore
    private var scoreBento: some View {
        BentoCard(backgroundColor: AppColors.boxRed, cornerRadius: 40) { // Push radius higher
            VStack(alignment: .leading, spacing: -8) {
                HStack(alignment: .top) {
                    Text("DEV SCORE")
                        .clash(size: 18, weight: .bold)
                        .foregroundStyle(.black.opacity(0.8))
                        .tracking(1.5)
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.black)
                }

                Spacer()

                Text("\(viewModel.devScore.compositeScore)")
                    .clash(size: 110, weight: .bold)
                    .foregroundStyle(.black)
                    .tracking(-4) // Super tight number kerning
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .padding(.bottom, -12)

                HStack {
                    Text(viewModel.devScore.tier.uppercased())
                        .clash(size: 16, weight: .bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black, in: Capsule())
                    Spacer()
                }
                .padding(.bottom, 8)
            }
        }
        .frame(height: 240)
    }

    /// Tightly packed square metric blocks
    private func platformBento(title: String, score: String, sub: String, color: Color, icon: String) -> some View {
        BentoCard(backgroundColor: color, cornerRadius: 36) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.black)
                    Spacer()
                    Text(title)
                        .clash(size: 10, weight: .bold)
                        .foregroundStyle(.black.opacity(0.8))
                        .tracking(1)
                }

                Spacer()

                Text(score)
                    .clash(size: 54, weight: .bold)
                    .foregroundStyle(.black)
                    .tracking(-2)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.bottom, -4)

                Text(sub)
                    .clash(size: 12, weight: .bold)
                    .foregroundStyle(.black.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Extra deep-black companion block
struct StatsBlock: View {
    let streak: String
    let rank: String
    
    var body: some View {
        BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 36) {
            VStack(alignment: .leading, spacing: 0) {
                Text("STREAK")
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white.opacity(0.6))
                
                Text(streak)
                    .clash(size: 32, weight: .bold)
                    .foregroundStyle(.white)
                    .tracking(-1)
                
                Spacer()
                
                Text("RANK")
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white.opacity(0.6))
                
                Text(rank.prefix(5).uppercased())
                    .clash(size: 24, weight: .bold)
                    .foregroundStyle(AppColors.boxYellow)
                    .tracking(-1)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
