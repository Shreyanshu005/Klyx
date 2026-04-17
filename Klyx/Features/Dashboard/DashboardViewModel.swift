//
//  DashboardViewModel.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation
import Observation

/// Powers the main Dashboard tab — shows the unified DevScore,
/// platform summaries, and streak info at a glance.
@Observable
final class DashboardViewModel {
    var devScore: DevScore = .empty
    var isLoading = false
    var errorMessage: String?
    var lastSyncText: String = "Never synced"

    private let scoreCalculator: ScoreCalculator
    private let cache: CacheManager

    init(
        lcService: LeetCodeServiceProtocol = LeetCodeService(),
        ghService: GitHubServiceProtocol = GitHubService(),
        cfService: CodeforcesServiceProtocol = CodeforcesService(),
        cache: CacheManager = .shared
    ) {
        self.cache = cache
        self.scoreCalculator = ScoreCalculator(
            lcService: lcService,
            ghService: ghService,
            cfService: cfService,
            cache: cache
        )

        // Load cached score immediately for instant UI
        if let cached = cache.loadCodable(DevScore.self, forKey: CacheManager.Keys.devScore) {
            self.devScore = cached
            self.lastSyncText = cached.lastUpdated.timeAgo
        }
    }

    // MARK: - Actions

    @MainActor
    func refresh(
        lcUsername: String?,
        ghUsername: String?,
        ghToken: String?,
        cfHandle: String?
    ) async {
        isLoading = true
        errorMessage = nil

        let score = await scoreCalculator.computeScore(
            lcUsername: lcUsername,
            ghUsername: ghUsername,
            ghToken: ghToken,
            cfHandle: cfHandle
        )

        devScore = score
        lastSyncText = score.lastUpdated.timeAgo
        isLoading = false
    }
}
