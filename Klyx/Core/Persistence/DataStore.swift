//
//  DataStore.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation
import SwiftData

// MARK: - Cached User Profile

/// Stores the user's connected platform usernames and last fetched score.
/// Persisted via SwiftData so the app feels instant on relaunch.
@Model
final class UserProfile {
    var leetcodeUsername: String?
    var githubUsername: String?
    var codeforcesHandle: String?

    /// Serialized JSON of the last computed DevScore.
    var cachedScoreJSON: Data?

    var lastSyncDate: Date?

    init(
        leetcodeUsername: String? = nil,
        githubUsername: String? = nil,
        codeforcesHandle: String? = nil
    ) {
        self.leetcodeUsername = leetcodeUsername
        self.githubUsername = githubUsername
        self.codeforcesHandle = codeforcesHandle
    }

    // MARK: - Convenience

    var cachedScore: DevScore? {
        guard let data = cachedScoreJSON else { return nil }
        return try? JSONDecoder().decode(DevScore.self, from: data)
    }

    func updateScore(_ score: DevScore) {
        cachedScoreJSON = try? JSONEncoder().encode(score)
        lastSyncDate = .now
    }
}

// MARK: - Cached Heatmap Entry

/// Individual day entry for contribution/submission heatmaps.
/// Shared between GitHub contributions and LeetCode submissions.
@Model
final class HeatmapEntry {
    var platform: String       // "github", "leetcode"
    var date: Date
    var count: Int
    var colorHex: String?

    init(platform: String, date: Date, count: Int, colorHex: String? = nil) {
        self.platform = platform
        self.date = date
        self.count = count
        self.colorHex = colorHex
    }
}

// MARK: - Model Container Setup

enum DataStoreConfig {
    /// The shared SwiftData model container.
    /// TODO: Switch to `groupContainer: .identifier("group.com.shreyanshu.klyx")`
    /// once the Widget target is created and App Group entitlement is added in Xcode.
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            HeatmapEntry.self,
            FriendProfile.self
        ])

        let config = ModelConfiguration(
            "KlyxStore",
            schema: schema
        )

        return try ModelContainer(for: schema, configurations: [config])
    }
}
