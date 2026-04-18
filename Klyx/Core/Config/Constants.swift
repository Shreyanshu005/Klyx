import Foundation

/// App-wide constants.
/// API keys and secrets should be stored in a `.xcconfig` file (gitignored)
/// and accessed via `Bundle.main.infoDictionary`.
enum Constants {
    // MARK: - App Group

    /// Shared App Group identifier for main app ↔ widget data sharing.
    /// Shared App Group identifier for main app ↔ widget data sharing.
    static let appGroupID = "group.appminds.klyxx"

    // MARK: - API Base URLs

    static let leetcodeGraphQL = "https://leetcode.com/graphql"
    static let githubAPI = "https://api.github.com"
    static let githubGraphQL = "https://api.github.com/graphql"
    static let codeforcesAPI = "https://codeforces.com/api"

    // MARK: - Cache TTL (seconds)

    static let defaultCacheTTL: TimeInterval = 15 * 60
    static let heatmapCacheTTL: TimeInterval = 60 * 60
    static let profileCacheTTL: TimeInterval = 30 * 60

    // MARK: - Widget Refresh

    static let widgetRefreshInterval: TimeInterval = 30 * 60

    // MARK: - Score Weights

    /// Adjust these to change how the composite DevScore is calculated.
    enum ScoreWeights {
        static let leetcodeMax: Double = 350
        static let githubMax: Double = 350
        static let codeforcesMax: Double = 300
    }

    // MARK: - Config from .xcconfig

    /// Read a value from Info.plist (set via .xcconfig).
    static func configValue(forKey key: String) -> String? {
        Bundle.main.infoDictionary?[key] as? String
    }

    /// GitHub personal access token (from .xcconfig → Info.plist).
    static var githubToken: String? {
        configValue(forKey: "GITHUB_TOKEN")
    }
}
