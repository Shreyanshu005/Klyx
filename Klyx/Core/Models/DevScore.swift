//
//  DevScore.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

/// Unified score model that aggregates metrics from all platforms
/// into a single "Developer Score" for the dashboard and widgets.
struct DevScore: Codable, Identifiable {
    var id: UUID = UUID()
    let lastUpdated: Date

    // MARK: - LeetCode Metrics
    var lcRanking: Int?
    var lcEasySolved: Int
    var lcMediumSolved: Int
    var lcHardSolved: Int
    var lcTotalSolved: Int
    var lcContestRating: Double?
    var lcStreak: Int

    // MARK: - GitHub Metrics
    var ghTotalContributions: Int
    var ghCurrentStreak: Int
    var ghLongestStreak: Int
    var ghPublicRepos: Int
    var ghFollowers: Int
    var ghStars: Int

    // MARK: - Codeforces Metrics
    var cfRating: Int?
    var cfMaxRating: Int?
    var cfRank: String?
    var cfContestsAttended: Int
    var cfProblemsSolved: Int

    // MARK: - Derived Composite Score

    /// Weighted composite score (0–1000 scale).
    /// Tweak weights here based on what you value most.
    var compositeScore: Int {
        var score: Double = 0

        // LeetCode (max ~350 pts)
        let lcWeight = min(Double(lcTotalSolved) / 500.0, 1.0) * 200
        let lcContestWeight = min((lcContestRating ?? 0) / 3000.0, 1.0) * 150
        score += lcWeight + lcContestWeight

        // GitHub (max ~350 pts)
        let ghContribWeight = min(Double(ghTotalContributions) / 2000.0, 1.0) * 150
        let ghStreakWeight = min(Double(ghCurrentStreak) / 365.0, 1.0) * 100
        let ghStarWeight = min(Double(ghStars) / 500.0, 1.0) * 100
        score += ghContribWeight + ghStreakWeight + ghStarWeight

        // Codeforces (max ~300 pts)
        let cfRatingWeight = min(Double(cfRating ?? 0) / 2400.0, 1.0) * 200
        let cfSolvedWeight = min(Double(cfProblemsSolved) / 500.0, 1.0) * 100
        score += cfRatingWeight + cfSolvedWeight

        return min(Int(score), 1000)
    }

    /// Human-readable tier based on composite score.
    var tier: String {
        switch compositeScore {
        case 0..<200:    return "Beginner"
        case 200..<400:  return "Intermediate"
        case 400..<600:  return "Advanced"
        case 600..<800:  return "Expert"
        case 800...1000: return "Legendary"
        default:         return "Unknown"
        }
    }

    // MARK: - Empty Default

    static var empty: DevScore {
        DevScore(
            lastUpdated: .now,
            lcEasySolved: 0, lcMediumSolved: 0, lcHardSolved: 0, lcTotalSolved: 0,
            lcStreak: 0,
            ghTotalContributions: 0, ghCurrentStreak: 0, ghLongestStreak: 0,
            ghPublicRepos: 0, ghFollowers: 0, ghStars: 0,
            cfContestsAttended: 0, cfProblemsSolved: 0
        )
    }
}
