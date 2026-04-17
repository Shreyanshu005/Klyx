//
//  AggregatedStats.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

/// Pure raw aggregated metrics from all platforms without arbitrary score calculations.
struct AggregatedStats: Codable {
    var lastUpdated: Date

    // LeetCode
    var lcRanking: Int?
    var lcEasySolved: Int
    var lcMediumSolved: Int
    var lcHardSolved: Int
    var lcTotalSolved: Int
    var lcContestRating: Double?
    var lcStreak: Int

    // GitHub
    var ghTotalContributions: Int
    var ghCurrentStreak: Int
    var ghLongestStreak: Int
    var ghPublicRepos: Int
    var ghFollowers: Int
    var ghStars: Int

    // Codeforces
    var cfRating: Int?
    var cfMaxRating: Int?
    var cfRank: String?
    var cfContestsAttended: Int
    var cfProblemsSolved: Int
    
    // Derived Raw Metric for Leaderboard sorting logic
    var totalCompetitiveSolved: Int {
        return lcTotalSolved + cfProblemsSolved
    }
}
