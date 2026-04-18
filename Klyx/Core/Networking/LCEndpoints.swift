import Foundation

/// LeetCode API endpoints — uses their public GraphQL API.
enum LCEndpoints {
    static let baseURL = URL(string: "https://leetcode.com/graphql")!

    // MARK: - Queries

    /// Fetch a user's full profile (rank, solved counts, badges).
    static let userProfileQuery = """
    query getUserProfile($username: String!) {
        matchedUser(username: $username) {
            username
            profile {
                realName
                ranking
                userAvatar
                reputation
                starRating
            }
            submitStatsGlobal {
                acSubmissionNum {
                    difficulty
                    count
                }
            }
            badges {
                name
                icon
            }
        }
    }
    """

    /// Fetch the user's recent submission list.
    static let recentSubmissionsQuery = """
    query getRecentSubmissions($username: String!, $limit: Int!) {
        recentAcSubmissionList(username: $username, limit: $limit) {
            id
            title
            titleSlug
            timestamp
            lang
        }
    }
    """

    /// Fetch the user's contest history and rating.
    static let contestHistoryQuery = """
    query getUserContestInfo($username: String!) {
        userContestRanking(username: $username) {
            attendedContestsCount
            rating
            globalRanking
            topPercentage
        }
        userContestRankingHistory(username: $username) {
            contest {
                title
                startTime
            }
            rating
            ranking
        }
    }
    """

    /// Fetch the user's submission calendar (heatmap data).
    static let submissionCalendarQuery = """
    query getUserCalendar($username: String!) {
        matchedUser(username: $username) {
            submissionCalendar
        }
    }
    """
}
