import Foundation
import Observation

/// Powers the Competitive tab — LeetCode + Codeforces data.
@Observable
final class CompetitiveViewModel {
    // MARK: - LeetCode State
    var lcProfile: LCMatchedUser?
    var lcSubmissions: [LCSubmission] = []
    var lcContestData: LCContestData?
    var lcCalendar: [String: Int] = [:]

    // MARK: - Codeforces State
    var cfUser: CFUser?
    var cfRatingHistory: [CFRatingChange] = []
    var cfSubmissions: [CFSubmission] = []
    var cfUpcomingContests: [CFContest] = []

    // MARK: - UI State
    var isLoading = false
    var errorMessage: String?
    var selectedTab: CompetitiveTab = .leetcode

    enum CompetitiveTab: String, CaseIterable {
        case leetcode = "LeetCode"
        case codeforces = "Codeforces"
    }

    private let lcService: LeetCodeServiceProtocol
    private let cfService: CodeforcesServiceProtocol

    init(
        lcService: LeetCodeServiceProtocol = LeetCodeService(),
        cfService: CodeforcesServiceProtocol = CodeforcesService()
    ) {
        self.lcService = lcService
        self.cfService = cfService
    }

    // MARK: - LeetCode Actions

    @MainActor
    func fetchLeetCode(username: String) async {
        guard !username.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let profile = lcService.fetchProfile(username: username)
            async let submissions = lcService.fetchRecentSubmissions(username: username, limit: 20)
            async let contest = lcService.fetchContestHistory(username: username)
            async let calendar = lcService.fetchSubmissionCalendar(username: username)

            lcProfile = try await profile
            lcSubmissions = try await submissions
            lcContestData = try await contest
            lcCalendar = try await calendar
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Codeforces Actions

    @MainActor
    func fetchCodeforces(handle: String) async {
        guard !handle.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let user = cfService.fetchUserInfo(handle: handle)
            async let history = cfService.fetchRatingHistory(handle: handle)
            async let subs = cfService.fetchRecentSubmissions(handle: handle, count: 30)
            async let contests = cfService.fetchUpcomingContests()

            cfUser = try await user
            cfRatingHistory = try await history
            cfSubmissions = try await subs
            cfUpcomingContests = try await contests
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
