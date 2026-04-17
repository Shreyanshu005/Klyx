//
//  GitHubService.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

// MARK: - Protocol

protocol GitHubServiceProtocol {
    func fetchProfile(username: String) async throws -> GHUser
    func fetchContributions(username: String, token: String) async throws -> GHContributionCalendar
    func fetchRepos(username: String) async throws -> [GHRepo]
    func fetchStreaks(username: String, token: String) async throws -> (current: Int, longest: Int)
}

// MARK: - Implementation

final class GitHubService: GitHubServiceProtocol {
    private let client: APIClient
    private let cache: CacheManager

    init(client: APIClient = .shared, cache: CacheManager = .shared) {
        self.client = client
        self.cache = cache
    }

    func fetchProfile(username: String) async throws -> GHUser {
        let cacheKey = "gh_profile_\(username)"
        if let cached: GHUser = cache.get(cacheKey) { return cached }

        guard let url = GHEndpoints.userProfile(username: username) else {
            throw APIError.invalidURL
        }

        let user: GHUser = try await client.request(url: url)
        cache.set(cacheKey, value: user)
        return user
    }

    func fetchContributions(username: String, token: String) async throws -> GHContributionCalendar {
        let cacheKey = "gh_contributions_\(username)"
        if let cached: GHContributionCalendar = cache.get(cacheKey) { return cached }

        let response: GHGraphQLResponse = try await client.graphQL(
            url: GHEndpoints.graphQLURL,
            query: GHEndpoints.contributionCalendarQuery,
            variables: ["username": username],
            headers: GHEndpoints.authHeaders(token: token)
        )

        let calendar = response.data.user.contributionsCollection.contributionCalendar
        cache.set(cacheKey, value: calendar, ttl: Constants.heatmapCacheTTL)
        return calendar
    }

    func fetchRepos(username: String) async throws -> [GHRepo] {
        guard let url = GHEndpoints.userRepos(username: username) else {
            throw APIError.invalidURL
        }

        return try await client.request(url: url)
    }

    func fetchStreaks(username: String, token: String) async throws -> (current: Int, longest: Int) {
        let calendar = try await fetchContributions(username: username, token: token)
        let days = calendar.weeks.flatMap { $0.contributionDays }
        let dict = Dictionary(uniqueKeysWithValues: days.map { ($0.date, $0.contributionCount) })
        
        // 1. Longest Streak (anywhere in history)
        var longest = 0
        var temp = 0
        for day in days {
            if day.contributionCount > 0 {
                temp += 1
                longest = max(longest, temp)
            } else {
                temp = 0
            }
        }
        
        // 2. Current Streak (anchored to today/yesterday)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let yesterday = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        
        var current = 0
        if (dict[today] ?? 0) > 0 || (dict[yesterday] ?? 0) > 0 {
            var checkDate = (dict[today] ?? 0) > 0 ? Date() : Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            while true {
                let key = formatter.string(from: checkDate)
                if (dict[key] ?? 0) > 0 {
                    current += 1
                    guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else { break }
                    checkDate = prev
                } else {
                    break
                }
            }
        }
        
        return (current: current, longest: longest)
    }
}

// MARK: - Mock for Previews

final class MockGitHubService: GitHubServiceProtocol {
    func fetchProfile(username: String) async throws -> GHUser {
        GHUser(
            id: 1, login: "demo", name: "Demo User", avatarUrl: nil,
            bio: "iOS Developer", publicRepos: 25, publicGists: 5,
            followers: 120, following: 30, createdAt: nil, htmlUrl: nil
        )
    }

    func fetchContributions(username: String, token: String) async throws -> GHContributionCalendar {
        GHContributionCalendar(totalContributions: 450, weeks: [])
    }

    func fetchRepos(username: String) async throws -> [GHRepo] { [] }

    func fetchStreaks(username: String, token: String) async throws -> (current: Int, longest: Int) {
        (current: 15, longest: 42)
    }
}
