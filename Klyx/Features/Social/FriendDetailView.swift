//
//  FriendDetailView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import SwiftData

/// Detailed dive into a tracked friend's dynamic scores with everything expanded.
struct FriendDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var savedProfiles: [FriendProfile]
    
    let friend: String
    let score: DevScore

    private var trackedProfile: FriendProfile? {
        savedProfiles.first(where: { $0.alias == friend })
    }

    var body: some View {
        ZStack {
            AppColors.pureBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    
                    // MARK: - Banner
                    BentoCard(backgroundColor: AppColors.boxBlue, cornerRadius: 40) {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("COMPOSITE SCORE")
                                    .clash(size: 14, weight: .bold)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .tracking(1)
                                Spacer()
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                            }
                            
                            Spacer()
                            
                            Text("\(score.compositeScore)")
                                .clash(size: 90, weight: .bold)
                                .foregroundStyle(.white)
                                .tracking(-4)
                                .padding(.bottom, -12)

                            HStack {
                                Text(friend.uppercased())
                                    .clash(size: 24, weight: .bold)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppColors.boxYellow, in: Capsule())
                                
                                Text(score.tier.uppercased())
                                    .clash(size: 14, weight: .bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(.black, in: Capsule())
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    .frame(height: 240)

                    // MARK: - GitHub Details
                    BentoCard(backgroundColor: AppColors.boxGreen, cornerRadius: 28) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 20, weight: .black))
                                Text("GITHUB")
                                    .clash(size: 18, weight: .bold)
                                Spacer()
                            }
                            .foregroundStyle(.black)
                            
                            HStack {
                                detailStat(val: "\(score.ghTotalContributions)", title: "CONTRIBS", color: .black)
                                detailStat(val: "\(score.ghCurrentStreak)", title: "CURR STREAK", color: .black)
                                detailStat(val: "\(score.ghLongestStreak)", title: "MAX STREAK", color: .black)
                            }
                            HStack {
                                detailStat(val: "\(score.ghPublicRepos)", title: "REPOS", color: .black.opacity(0.6))
                                detailStat(val: "\(score.ghFollowers)", title: "FOLLOWERS", color: .black.opacity(0.6))
                                detailStat(val: "\(score.ghStars)", title: "STARS", color: .black.opacity(0.6))
                            }
                        }
                    }

                    // MARK: - LeetCode Details
                    BentoCard(backgroundColor: AppColors.boxYellow, cornerRadius: 28) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    .font(.system(size: 20, weight: .black))
                                Text("LEETCODE")
                                    .clash(size: 18, weight: .bold)
                                Spacer()
                            }
                            .foregroundStyle(.black)
                            
                            HStack {
                                detailStat(val: "\(score.lcTotalSolved)", title: "TOTAL SOLVED", color: .black)
                                detailStat(val: "\(score.lcRanking ?? 0)", title: "GLOBAL RANK", color: .black)
                                detailStat(val: String(format: "%.0f", score.lcContestRating ?? 0), title: "RATING", color: .black)
                            }
                            HStack {
                                detailStat(val: "\(score.lcEasySolved)", title: "EASY", color: .black.opacity(0.6))
                                detailStat(val: "\(score.lcMediumSolved)", title: "MEDIUM", color: .black.opacity(0.6))
                                detailStat(val: "\(score.lcHardSolved)", title: "HARD", color: AppColors.boxRed)
                            }
                        }
                    }

                    // MARK: - Codeforces Details
                    BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 20, weight: .black))
                                Text("CODEFORCES")
                                    .clash(size: 18, weight: .bold)
                                Spacer()
                            }
                            .foregroundStyle(AppColors.boxBlue)
                            
                            HStack {
                                detailStat(val: "\(score.cfRating ?? 0)", title: "RATING", color: .white)
                                detailStat(val: "\(score.cfMaxRating ?? 0)", title: "PEAK", color: .white)
                                detailStat(val: score.cfRank ?? "N/A", title: "RANK", color: AppColors.boxYellow)
                            }
                            HStack {
                                detailStat(val: "\(score.cfContestsAttended)", title: "CONTESTS", color: .white.opacity(0.6))
                                detailStat(val: "\(score.cfProblemsSolved)", title: "SOLVED", color: .white.opacity(0.6))
                                detailStat(val: "", title: "", color: .clear) // alignment spacer
                            }
                        }
                    }

                    // MARK: - Remove Action
                    Button(role: .destructive, action: removeFriend) {
                        BentoCard(backgroundColor: AppColors.boxRed, cornerRadius: 24) {
                            HStack {
                                Spacer()
                                Text("REMOVE FRIEND")
                                    .clash(size: 16, weight: .bold)
                                    .foregroundStyle(.white)
                                    .tracking(1)
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 64)
                    .padding(.top, 24)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailStat(val: String, title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(val.uppercased())
                .clash(size: 24, weight: .bold)
                .foregroundStyle(color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(title)
                .clash(size: 10, weight: .bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func removeFriend() {
        if let target = trackedProfile {
            modelContext.delete(target)
            try? modelContext.save()
            dismiss()
        }
    }
}
