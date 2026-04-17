//
//  ScoreCalculator.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation
import WidgetKit

/// Aggregates data from all three platforms into a unified DevScore.
/// Called after each sync to recompute the dashboard metrics.
final class ScoreCalculator {
    private let lcService: LeetCodeServiceProtocol
    private let ghService: GitHubServiceProtocol
    private let cfService: CodeforcesServiceProtocol
    private let cache: CacheManager

    init(
        lcService: LeetCodeServiceProtocol,
        ghService: GitHubServiceProtocol,
        cfService: CodeforcesServiceProtocol,
        cache: CacheManager = .shared
    ) {
        self.lcService = lcService
        self.ghService = ghService
        self.cfService = cfService
        self.cache = cache
    }

    /// Fetch from all platforms and compute a fresh DevScore.
    func computeScore(
        lcUsername: String?,
        ghUsername: String?,
        ghToken: String?,
        cfHandle: String?
    ) async -> DevScore {
        async let lcData = fetchLeetCode(username: lcUsername)
        async let ghData = fetchGitHub(username: ghUsername, token: ghToken)
        async let cfData = fetchCodeforces(handle: cfHandle)

        let lc = await lcData
        let gh = await ghData
        let cf = await cfData

        let score = DevScore(
            lastUpdated: .now,
            lcRanking: lc.ranking,
            lcEasySolved: lc.easy,
            lcMediumSolved: lc.medium,
            lcHardSolved: lc.hard,
            lcTotalSolved: lc.easy + lc.medium + lc.hard,
            lcContestRating: lc.contestRating,
            lcStreak: lc.streak,
            ghTotalContributions: gh.contributions,
            ghCurrentStreak: gh.currentStreak,
            ghLongestStreak: gh.longestStreak,
            ghPublicRepos: gh.repos,
            ghFollowers: gh.followers,
            ghStars: gh.stars,
            cfRating: cf.rating,
            cfMaxRating: cf.maxRating,
            cfRank: cf.rank,
            cfContestsAttended: cf.contests,
            cfProblemsSolved: cf.solved
        )

        // Persist for widget access
        cache.persistCodable(score, forKey: CacheManager.Keys.devScore)

        // Tell widgets to refresh immediately
        WidgetCenter.shared.reloadAllTimelines()

        return score
    }

    // MARK: - Private Fetchers

    private struct LCMetrics {
        var ranking: Int? = nil
        var easy = 0; var medium = 0; var hard = 0
        var contestRating: Double? = nil
        var streak = 0
    }

    private func fetchLeetCode(username: String?) async -> LCMetrics {
        guard let username, !username.isEmpty else { return LCMetrics() }
        var metrics = LCMetrics()

        do {
            let profile = try await lcService.fetchProfile(username: username)
            metrics.ranking = profile.profile.ranking
            for stat in profile.submitStatsGlobal?.acSubmissionNum ?? [] {
                switch stat.difficulty {
                case "Easy": metrics.easy = stat.count
                case "Medium": metrics.medium = stat.count
                case "Hard": metrics.hard = stat.count
                default: break
                }
            }

            let contest = try await lcService.fetchContestHistory(username: username)
            metrics.contestRating = contest.userContestRanking?.rating
            
            // Persist the heatmap calendar explicitly for widget access
            let calendar = try await lcService.fetchSubmissionCalendar(username: username)
            cache.persistCodable(calendar, forKey: CacheManager.Keys.lcProfile)
        } catch {
            print("[ScoreCalculator] LC fetch error: \(error.localizedDescription)")
        }

        return metrics
    }

    private struct GHMetrics {
        var contributions = 0; var currentStreak = 0; var longestStreak = 0
        var repos = 0; var followers = 0; var stars = 0
    }

    private func fetchGitHub(username: String?, token: String?) async -> GHMetrics {
        guard let username, !username.isEmpty else { return GHMetrics() }
        var metrics = GHMetrics()

        do {
            let profile = try await ghService.fetchProfile(username: username)
            metrics.repos = profile.publicRepos
            metrics.followers = profile.followers

            if let token, !token.isEmpty {
                let calendar = try await ghService.fetchContributions(username: username, token: token)
                metrics.contributions = calendar.totalContributions
                
                // Persist the actual flat calendar to App Group for widgets
                var simplifiedMap: [String: Int] = [:]
                for week in calendar.weeks {
                    for day in week.contributionDays {
                        simplifiedMap[day.date] = day.contributionCount
                    }
                }
                cache.persistCodable(simplifiedMap, forKey: CacheManager.Keys.ghProfile)

                let streaks = try await ghService.fetchStreaks(username: username, token: token)
                metrics.currentStreak = streaks.current
                metrics.longestStreak = streaks.longest
            }

            let repos = try await ghService.fetchRepos(username: username)
            metrics.stars = repos.reduce(0) { $0 + $1.stargazersCount }
        } catch {
            print("[ScoreCalculator] GH fetch error: \(error.localizedDescription)")
        }

        return metrics
    }

    private struct CFMetrics {
        var rating: Int? = nil; var maxRating: Int? = nil
        var rank: String? = nil; var contests = 0; var solved = 0
    }

    private func fetchCodeforces(handle: String?) async -> CFMetrics {
        guard let handle, !handle.isEmpty else { return CFMetrics() }
        var metrics = CFMetrics()

        do {
            let user = try await cfService.fetchUserInfo(handle: handle)
            metrics.rating = user.rating
            metrics.maxRating = user.maxRating
            metrics.rank = user.rank

            let history = try await cfService.fetchRatingHistory(handle: handle)
            metrics.contests = history.count

            let submissions = try await cfService.fetchRecentSubmissions(handle: handle, count: 100)
            let uniqueSolved = Set(submissions.filter { $0.isAccepted }.map { $0.problem.displayName })
            metrics.solved = uniqueSolved.count
        } catch {
            print("[ScoreCalculator] CF fetch error: \(error.localizedDescription)")
        }

        return metrics
    }
}
