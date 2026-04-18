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
        let stats: AggregatedStats
    }

    struct LeaderboardEntry: Identifiable {
        let id = UUID()
        let rank: Int
        let alias: String
        let stats: AggregatedStats
    }

    // MARK: - Actions

    @MainActor
    func loadFriends(profiles: [FriendProfile]) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        friends.removeAll()

        let token = KeychainManager.shared.loadString(forKey: KeychainManager.Keys.githubToken)

        await withTaskGroup(of: FriendEntry?.self) { group in
            for profile in profiles {
                group.addTask {
                    let calc = ScoreCalculator(
                        lcService: LeetCodeService(),
                        ghService: GitHubService(),
                        cfService: CodeforcesService()
                    )

                    let stats = await calc.computeScore(
                        lcUsername: profile.leetcodeUsername,
                        ghUsername: profile.githubUsername,
                        ghToken: token,
                        cfHandle: profile.codeforcesHandle
                    )

                    return FriendEntry(profile: profile, stats: stats)
                }
            }

            for await result in group {
                if let entry = result {
                    friends.append(entry)
                }
            }
        }

        leaderboard = friends
            .sorted { $0.stats.totalCompetitiveSolved > $1.stats.totalCompetitiveSolved }
            .enumerated()
            .map { index, friend in
                LeaderboardEntry(
                    rank: index + 1,
                    alias: friend.profile.alias,
                    stats: friend.stats
                )
            }

        isLoading = false
    }
}
