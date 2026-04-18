import Foundation

// MARK: - GraphQL Response Wrappers

struct LCGraphQLResponse<T: Decodable>: Decodable {
    let data: T
}

// MARK: - User Profile

struct LCUserProfileData: Decodable {
    let matchedUser: LCMatchedUser?
}

struct LCMatchedUser: Decodable {
    let username: String
    let profile: LCProfile
    let submitStatsGlobal: LCSubmitStats?
    let badges: [LCBadge]?
}

struct LCProfile: Decodable {
    let realName: String?
    let ranking: Int?
    let userAvatar: String?
    let reputation: Int?
    let starRating: Double?
}

struct LCSubmitStats: Decodable {
    let acSubmissionNum: [LCDifficultyCount]
}

struct LCDifficultyCount: Decodable {
    let difficulty: String
    let count: Int
}

struct LCBadge: Decodable {
    let name: String
    let icon: String?
}

// MARK: - Recent Submissions

struct LCRecentSubmissionsData: Decodable {
    let recentAcSubmissionList: [LCSubmission]?
}

struct LCSubmission: Decodable, Identifiable {
    let id: String
    let title: String
    let titleSlug: String
    let timestamp: String
    let lang: String

    var date: Date? {
        guard let interval = TimeInterval(timestamp) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
}

// MARK: - Contest History

struct LCContestData: Decodable {
    let userContestRanking: LCContestRanking?
    let userContestRankingHistory: [LCContestEntry]?
}

struct LCContestRanking: Decodable {
    let attendedContestsCount: Int
    let rating: Double
    let globalRanking: Int
    let topPercentage: Double
}

struct LCContestEntry: Decodable, Identifiable {
    var id: String { contest.title }
    let contest: LCContest
    let rating: Double
    let ranking: Int
}

struct LCContest: Decodable {
    let title: String
    let startTime: Int
}

// MARK: - Submission Calendar (Heatmap)

struct LCCalendarData: Decodable {
    let matchedUser: LCCalendarUser?
}

struct LCCalendarUser: Decodable {
    /// JSON string of unix-timestamp → count, e.g. `{"1680307200": 3, ...}`
    let submissionCalendar: String?
}
