import Foundation

/// The unified data model representing a developer's aggregated metrics
/// across all integrated competitive programming and open-source platforms.
///
/// `AggregatedStats` is the **single source of truth** for the Dashboard UI,
/// the Home Screen Widgets, and the Social Leaderboard. It is computed by
/// ``ScoreCalculator`` after concurrent API fetches and persisted to the
/// shared App Group container for cross-process widget access.
///
/// ## Platforms
/// - **LeetCode**: Problem solve counts by difficulty, contest rating, and streak.
/// - **GitHub**: Contribution totals, streak tracking, repository and follower counts.
/// - **Codeforces**: Competitive rating, rank, contest participation, and unique solves.
struct AggregatedStats: Codable {

    /// Timestamp of the last successful data synchronization.
    var lastUpdated: Date

    // MARK: - LeetCode Metrics

    /// Global ranking on LeetCode. `nil` if the user has no LeetCode profile.
    var lcRanking: Int?
    /// Number of Easy-difficulty problems solved.
    var lcEasySolved: Int
    /// Number of Medium-difficulty problems solved.
    var lcMediumSolved: Int
    /// Number of Hard-difficulty problems solved.
    var lcHardSolved: Int
    /// Total problems solved across all difficulties.
    var lcTotalSolved: Int
    /// LeetCode Weekly/Biweekly contest rating. `nil` if unrated.
    var lcContestRating: Double?
    /// Current consecutive-day submission streak on LeetCode.
    var lcStreak: Int

    // MARK: - GitHub Metrics

    /// Total contributions (commits, PRs, issues, reviews) in the past year.
    var ghTotalContributions: Int
    /// Current consecutive-day contribution streak on GitHub.
    var ghCurrentStreak: Int
    /// Longest-ever consecutive-day contribution streak.
    var ghLongestStreak: Int
    /// Number of public repositories owned by the user.
    var ghPublicRepos: Int
    /// Number of followers on GitHub.
    var ghFollowers: Int
    /// Total stars received across all public repositories.
    var ghStars: Int

    // MARK: - Codeforces Metrics

    /// Current Codeforces rating. `nil` if the user is unrated.
    var cfRating: Int?
    /// Peak Codeforces rating achieved.
    var cfMaxRating: Int?
    /// Current Codeforces rank title (e.g., "specialist", "expert").
    var cfRank: String?
    /// Total number of rated contests participated in.
    var cfContestsAttended: Int
    /// Number of unique problems solved (from recent submissions).
    var cfProblemsSolved: Int

    // MARK: - Derived Metrics

    /// Combined competitive problem count used for leaderboard ranking.
    ///
    /// Calculated as `lcTotalSolved + cfProblemsSolved`.
    var totalCompetitiveSolved: Int {
        return lcTotalSolved + cfProblemsSolved
    }
}
