//
//  GitHubViewModel.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation
import Observation

/// Powers the GitHub tab — profile, contribution heatmap, repos, and streaks.
@Observable
final class GitHubViewModel {
    var profile: GHUser?
    var contributionCalendar: GHContributionCalendar?
    var repos: [GHRepo] = []
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalStars: Int = 0

    var isLoading = false
    var errorMessage: String?

    private let ghService: GitHubServiceProtocol

    init(ghService: GitHubServiceProtocol = GitHubService()) {
        self.ghService = ghService
    }

    // MARK: - Actions

    @MainActor
    func fetchAll(username: String, token: String?) async {
        guard !username.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            // Profile + repos (no token needed)
            async let profileTask = ghService.fetchProfile(username: username)
            async let reposTask = ghService.fetchRepos(username: username)

            profile = try await profileTask
            repos = try await reposTask
            totalStars = repos.reduce(0) { $0 + $1.stargazersCount }

            // Contributions + streaks (requires token for GraphQL)
            if let token, !token.isEmpty {
                async let calendarTask = ghService.fetchContributions(username: username, token: token)
                async let streakTask = ghService.fetchStreaks(username: username, token: token)

                contributionCalendar = try await calendarTask
                let streaks = try await streakTask
                currentStreak = streaks.current
                longestStreak = streaks.longest
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
