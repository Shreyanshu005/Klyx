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
    @Binding var selectedTab: RootView.Tab
    @Query private var profiles: [UserProfile]
    @State private var viewModel = DashboardViewModel()
    @State private var animatedCompetitiveSolved: Int = 0

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
                            if let stats = viewModel.aggregatedStats {
                                VStack(spacing: 12) {
                                    // 1. Hero Solved Card (Replaces DevScore)
                                    scoreBento(stats: stats)
                                    
                                    // 1.5 Weekly LeetCode Progress
                                    if let lcData = CacheManager.shared.loadCodable([String: Int].self, forKey: CacheManager.Keys.lcProfile) {
                                        WeeklyProgressView(
                                            data: lcData,
                                            color: AppColors.boxYellow,
                                            title: "LEETCODE WEEKLY"
                                        )
                                        .padding(.horizontal, 4)
                                    }
                                    
                                    // 2. Platform Sub-Scores
                                    HStack(spacing: 12) {
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedTab = .github
                                            }
                                        } label: {
                                            platformBento(
                                                title: "GITHUB",
                                                score: "\(stats.ghTotalContributions)",
                                                sub: "CONTRIBS",
                                                color: AppColors.boxGreen,
                                                textColor: .white,
                                                icon: "arrow.triangle.branch"
                                            )
                                        }
                                        .buttonStyle(BouncyButtonStyle())
                                        
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedTab = .competitive
                                                // Ideally should also switch the competitive VM tab to .leetcode, but navigation is enough
                                            }
                                        } label: {
                                            platformBento(
                                                title: "LEETCODE",
                                                score: "\(stats.lcTotalSolved)",
                                                sub: "SOLVED",
                                                color: AppColors.boxYellow,
                                                textColor: .black,
                                                icon: "chevron.left.forwardslash.chevron.right"
                                            )
                                        }
                                        .buttonStyle(BouncyButtonStyle())
                                    }
                                    .frame(height: 160)

                                    // 3. Codeforces Single Wide Bento
                                    HStack {
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedTab = .competitive
                                            }
                                        } label: {
                                            platformBento(
                                                title: "CODEFORCES",
                                                score: "\(stats.cfRating ?? 0)",
                                                sub: "RATING",
                                                color: AppColors.boxBlue,
                                                textColor: .white,
                                                icon: "trophy.fill"
                                            )
                                        }
                                        .buttonStyle(BouncyButtonStyle())
                                        
                                        StatsBlock(
                                            streak: "\(stats.ghCurrentStreak)D",
                                            rank: stats.cfRank ?? "UNRATED"
                                        )
                                    }
                                    .frame(height: 160)

                                    // 4. Weekly LeetCode Tracker Component
                                    BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("LEETCODE STREAK")
                                                    .clash(size: 14, weight: .bold)
                                                    .foregroundStyle(.white.opacity(0.6))
                                                    .tracking(1)
                                                Text("\(stats.lcStreak) DAYS")
                                                    .clash(size: 32, weight: .bold)
                                                    .foregroundStyle(AppColors.boxYellow)
                                            }
                                            Spacer()
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 32))
                                                .foregroundStyle(AppColors.boxRed)
                                        }
                                    }
                                    .frame(height: 100)
                                }
                            } else {
                                BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .tint(AppColors.boxYellow)
                                            .scaleEffect(1.8)
                                        Text("FETCHING STATISTICS")
                                            .clash(size: 14, weight: .bold)
                                            .foregroundStyle(.white.opacity(0.5))
                                            .tracking(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 40)
                                }
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

                    if !CacheManager.shared.isSuiteAccessible {
                        HStack {
                            Image(systemName: "exclamationmark.shield.fill")
                            Text("APP GROUP DISCONNECTED - CHECK XCODE")
                        }
                        .clash(size: 10, weight: .bold)
                        .foregroundStyle(AppColors.boxRed)
                        .padding(.bottom, 20)
                    }
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

    /// Massive Hero Banner for the Aggregated Solved
    private func scoreBento(stats: AggregatedStats) -> some View {
        BentoCard(backgroundColor: AppColors.boxRed, cornerRadius: 40) { // Push radius higher
            VStack(alignment: .leading, spacing: -8) {
                HStack(alignment: .top) {
                    Text("COMPETITIVE SOLVED")
                        .clash(size: 16, weight: .bold)
                        .foregroundStyle(AppColors.textRedShade) // Precise text shade requested
                        .tracking(1)
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 12)
                
                Spacer()

                Text("\(stats.totalCompetitiveSolved)")
                    .animatingNumber(animatedCompetitiveSolved)
                    .foregroundStyle(.white)
                    .tracking(-4)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .onChange(of: stats.totalCompetitiveSolved) { oldValue, newValue in
                        withAnimation(.interpolatingSpring(stiffness: 40, damping: 15)) {
                            animatedCompetitiveSolved = newValue
                        }
                    }
                    .onAppear {
                        if animatedCompetitiveSolved == 0 {
                            withAnimation(.interpolatingSpring(stiffness: 40, damping: 15)) {
                                animatedCompetitiveSolved = stats.totalCompetitiveSolved
                            }
                        }
                    }
                
                HStack {
                    Text("GLOBAL")
                        .clash(size: 20, weight: .bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("LATEST: \(viewModel.lastSyncText.uppercased())")
                        .clash(size: 12, weight: .bold)
                        .foregroundStyle(AppColors.textRedShade)
                }
            }
        }
        .frame(height: 240)
    }

    private func platformBento(title: String, score: String, sub: String, color: Color, textColor: Color, icon: String) -> some View {
        BentoCard(backgroundColor: color, cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .black))
                    Spacer()
                }
                .foregroundStyle(textColor)

                Spacer()

                Text(score)
                    .clash(size: 54, weight: .bold)
                    .foregroundStyle(textColor)
                    .tracking(-2)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.bottom, -4)

                Text(sub)
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(textColor.opacity(0.8))
            }
        }
    }
}

/// Helper block extracting the secondary metrics into a stacked UI
struct StatsBlock: View {
    let streak: String
    let rank: String
    
    var body: some View {
        VStack(spacing: 12) {
            BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(streak)
                        .clash(size: 28, weight: .bold)
                        .foregroundStyle(.white)
                    Text("GH STREAK")
                        .clash(size: 10, weight: .bold)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(rank.uppercased())
                        .clash(size: 20, weight: .bold)
                        .foregroundStyle(AppColors.boxYellow)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("CF RANK")
                        .clash(size: 10, weight: .bold)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Custom Tactile Button Style
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
