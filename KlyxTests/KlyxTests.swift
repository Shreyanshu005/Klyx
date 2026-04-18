//
//  KlyxTests.swift
//  KlyxTests
//
//  Created by Shreyanshu on 17/04/26.
//

import Testing
import Foundation
@testable import Klyx

// MARK: - AggregatedStats Tests

struct AggregatedStatsTests {

    @Test func totalCompetitiveSolvedSumsCorrectly() {
        let stats = AggregatedStats(
            lastUpdated: .now,
            lcRanking: nil, lcEasySolved: 50, lcMediumSolved: 30, lcHardSolved: 10,
            lcTotalSolved: 90, lcContestRating: nil, lcStreak: 5,
            ghTotalContributions: 200, ghCurrentStreak: 10, ghLongestStreak: 30,
            ghPublicRepos: 15, ghFollowers: 50, ghStars: 100,
            cfRating: 1400, cfMaxRating: 1500, cfRank: "specialist",
            cfContestsAttended: 20, cfProblemsSolved: 60
        )

        #expect(stats.totalCompetitiveSolved == 150)
    }

    @Test func totalCompetitiveSolvedWithZeroCf() {
        let stats = AggregatedStats(
            lastUpdated: .now,
            lcRanking: nil, lcEasySolved: 100, lcMediumSolved: 50, lcHardSolved: 20,
            lcTotalSolved: 170, lcContestRating: nil, lcStreak: 0,
            ghTotalContributions: 0, ghCurrentStreak: 0, ghLongestStreak: 0,
            ghPublicRepos: 0, ghFollowers: 0, ghStars: 0,
            cfRating: nil, cfMaxRating: nil, cfRank: nil,
            cfContestsAttended: 0, cfProblemsSolved: 0
        )

        #expect(stats.totalCompetitiveSolved == 170)
    }

    @Test func encodingDecodingRoundTrip() throws {
        let original = AggregatedStats(
            lastUpdated: Date(timeIntervalSince1970: 1700000000),
            lcRanking: 50000, lcEasySolved: 100, lcMediumSolved: 80, lcHardSolved: 20,
            lcTotalSolved: 200, lcContestRating: 1850.5, lcStreak: 12,
            ghTotalContributions: 500, ghCurrentStreak: 15, ghLongestStreak: 45,
            ghPublicRepos: 25, ghFollowers: 120, ghStars: 300,
            cfRating: 1600, cfMaxRating: 1750, cfRank: "expert",
            cfContestsAttended: 35, cfProblemsSolved: 80
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AggregatedStats.self, from: data)

        #expect(decoded.lcTotalSolved == original.lcTotalSolved)
        #expect(decoded.cfProblemsSolved == original.cfProblemsSolved)
        #expect(decoded.totalCompetitiveSolved == original.totalCompetitiveSolved)
        #expect(decoded.ghTotalContributions == original.ghTotalContributions)
        #expect(decoded.cfRank == "expert")
    }
}

// MARK: - Date Extension Tests

struct DateHelperTests {

    @Test func isoDateStringFormat() {
        let date = Date(timeIntervalSince1970: 0) // Jan 1, 1970 UTC
        let result = date.isoDateString
        // Format should be yyyy-MM-dd
        #expect(result.count == 10)
        #expect(result.contains("-"))
    }

    @Test func startOfDayStripsTime() {
        let now = Date.now
        let sod = now.startOfDay
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: sod)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test func daysBetweenCalculation() {
        let today = Date.now.startOfDay
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        #expect(today.daysBetween(threeDaysAgo) == 3)
    }

    @Test func pastDaysReturnsCorrectCount() {
        let days = Date.pastDays(7)
        #expect(days.count == 7)
    }
}

// MARK: - ServiceContainer Tests

struct ServiceContainerTests {

    @Test func liveContainerCreatesRealServices() {
        let container = ServiceContainer.live
        #expect(container.leetcode is LeetCodeService)
        #expect(container.github is GitHubService)
        #expect(container.codeforces is CodeforcesService)
    }

    @Test func mockContainerCreatesMockServices() {
        let container = ServiceContainer.mock
        #expect(container.leetcode is MockLeetCodeService)
        #expect(container.github is MockGitHubService)
        #expect(container.codeforces is MockCodeforcesService)
    }
}

// MARK: - Color Extension Tests

struct ColorHexTests {

    @Test func hexColorCreation() {
        // Should not crash with valid hex
        let _ = AppColors.boxRed
        let _ = AppColors.boxYellow
        let _ = AppColors.boxBlue
        let _ = AppColors.boxGreen
        let _ = AppColors.pureBlack
    }

    @Test func cfRatingColorRange() {
        // All rating ranges should return valid colors
        let _ = AppColors.cfRatingColor(800)   // Gray
        let _ = AppColors.cfRatingColor(1200)  // Green
        let _ = AppColors.cfRatingColor(1400)  // Cyan
        let _ = AppColors.cfRatingColor(1600)  // Blue
        let _ = AppColors.cfRatingColor(1900)  // Purple
        let _ = AppColors.cfRatingColor(2100)  // Orange
        let _ = AppColors.cfRatingColor(2400)  // Red
        let _ = AppColors.cfRatingColor(3000)  // Deep Red
    }
}

// MARK: - API Error Tests

struct APIErrorTests {

    @Test func errorDescriptionsAreNotNil() {
        let errors: [APIError] = [
            .invalidURL,
            .invalidResponse,
            .httpError(statusCode: 404, data: nil),
            .decodingError(NSError(domain: "", code: 0)),
            .networkError(NSError(domain: "", code: 0)),
            .rateLimited,
            .unauthorized
        ]

        for error in errors {
            #expect(error.errorDescription != nil)
        }
    }
}
