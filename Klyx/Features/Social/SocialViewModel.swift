//
//  SocialViewModel.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import Observation
import SwiftData

/// Powers the Social tab — dynamic friends list and leaderboard rankings.
@Observable
final class SocialViewModel {
    var friends: [FriendEntry] = []
    var leaderboard: [LeaderboardEntry] = []
    var isLoading = false
    var errorMessage: String?
    var syncProgress: String = ""

    // MARK: - Models

    struct FriendEntry: Identifiable {
        let id = UUID()
        let profile: FriendProfile
        let devScore: DevScore
    }

    struct LeaderboardEntry: Identifiable {
        let id = UUID()
        let rank: Int
        let alias: String
        let devScore: DevScore
    }

    // MARK: - Actions

    @MainActor
    func loadFriends(profiles: [FriendProfile]) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        friends.removeAll()

        let token = KeychainManager.shared.loadString(forKey: KeychainManager.Keys.githubToken)

        // Fetch each friend's score concurrently using task group
        await withTaskGroup(of: FriendEntry?.self) { group in
            for profile in profiles {
                group.addTask {
                    let calc = ScoreCalculator(
                        lcService: LeetCodeService(),
                        ghService: GitHubService(),
                        cfService: CodeforcesService()
                    )

                    let score = await calc.computeScore(
                        lcUsername: profile.leetcodeUsername,
                        ghUsername: profile.githubUsername,
                        ghToken: token,
                        cfHandle: profile.codeforcesHandle
                    )

                    return FriendEntry(profile: profile, devScore: score)
                }
            }

            for await result in group {
                if let entry = result {
                    friends.append(entry)
                }
            }
        }

        // Generate Leaderboard
        leaderboard = friends
            .sorted { $0.devScore.compositeScore > $1.devScore.compositeScore }
            .enumerated()
            .map { index, friend in
                LeaderboardEntry(
                    rank: index + 1,
                    alias: friend.profile.alias,
                    devScore: friend.devScore
                )
            }

        isLoading = false
    }
}
