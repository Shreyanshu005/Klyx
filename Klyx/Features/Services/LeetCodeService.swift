//
//  LeetCodeService.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

// MARK: - Protocol

protocol LeetCodeServiceProtocol {
    func fetchProfile(username: String) async throws -> LCMatchedUser
    func fetchRecentSubmissions(username: String, limit: Int) async throws -> [LCSubmission]
    func fetchContestHistory(username: String) async throws -> LCContestData
    func fetchSubmissionCalendar(username: String) async throws -> [String: Int]
}

// MARK: - Implementation

final class LeetCodeService: LeetCodeServiceProtocol {
    private let client: APIClient
    private let cache: CacheManager

    /// Headers required by LeetCode's GraphQL API.
    private let lcHeaders: [String: String] = [
        "Referer": "https://leetcode.com",
        "Origin": "https://leetcode.com",
        "Content-Type": "application/json"
    ]

    init(client: APIClient = .shared, cache: CacheManager = .shared) {
        self.client = client
        self.cache = cache
    }

    func fetchProfile(username: String) async throws -> LCMatchedUser {
        let cacheKey = "lc_profile_\(username)"
        if let cached: LCMatchedUser = cache.get(cacheKey) { return cached }

        let response: LCGraphQLResponse<LCUserProfileData> = try await client.graphQL(
            url: LCEndpoints.baseURL,
            query: LCEndpoints.userProfileQuery,
            variables: ["username": username],
            headers: lcHeaders
        )

        guard let user = response.data.matchedUser else {
            throw APIError.invalidResponse
        }

        cache.set(cacheKey, value: user)
        return user
    }

    func fetchRecentSubmissions(username: String, limit: Int = 20) async throws -> [LCSubmission] {
        let response: LCGraphQLResponse<LCRecentSubmissionsData> = try await client.graphQL(
            url: LCEndpoints.baseURL,
            query: LCEndpoints.recentSubmissionsQuery,
            variables: ["username": username, "limit": limit],
            headers: lcHeaders
        )

        return response.data.recentAcSubmissionList ?? []
    }

    func fetchContestHistory(username: String) async throws -> LCContestData {
        let response: LCGraphQLResponse<LCContestData> = try await client.graphQL(
            url: LCEndpoints.baseURL,
            query: LCEndpoints.contestHistoryQuery,
            variables: ["username": username],
            headers: lcHeaders
        )

        return response.data
    }

    func fetchSubmissionCalendar(username: String) async throws -> [String: Int] {
        let response: LCGraphQLResponse<LCCalendarData> = try await client.graphQL(
            url: LCEndpoints.baseURL,
            query: LCEndpoints.submissionCalendarQuery,
            variables: ["username": username],
            headers: lcHeaders
        )

        guard let calendarString = response.data.matchedUser?.submissionCalendar,
              let data = calendarString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
            return [:]
        }

        var normalizedDict: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // LeetCode timestamps are returned as UTC midnights
        formatter.timeZone = TimeZone(secondsFromGMT: 0) 

        for (timestampStr, count) in dict {
            if let interval = TimeInterval(timestampStr) {
                let date = Date(timeIntervalSince1970: interval)
                let dateString = formatter.string(from: date)
                normalizedDict[dateString] = count
            }
        }

        return normalizedDict
    }
}

// MARK: - Mock for Previews

final class MockLeetCodeService: LeetCodeServiceProtocol {
    func fetchProfile(username: String) async throws -> LCMatchedUser {
        LCMatchedUser(
            username: "demo_user",
            profile: LCProfile(realName: "Demo User", ranking: 50000, userAvatar: nil, reputation: 100, starRating: 4.5),
            submitStatsGlobal: LCSubmitStats(acSubmissionNum: [
                LCDifficultyCount(difficulty: "Easy", count: 120),
                LCDifficultyCount(difficulty: "Medium", count: 85),
                LCDifficultyCount(difficulty: "Hard", count: 30)
            ]),
            badges: []
        )
    }

    func fetchRecentSubmissions(username: String, limit: Int) async throws -> [LCSubmission] { [] }
    func fetchContestHistory(username: String) async throws -> LCContestData {
        LCContestData(userContestRanking: nil, userContestRankingHistory: nil)
    }
    func fetchSubmissionCalendar(username: String) async throws -> [String: Int] { [:] }
}
