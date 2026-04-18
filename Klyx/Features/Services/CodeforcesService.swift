import Foundation

// MARK: - Protocol

protocol CodeforcesServiceProtocol {
    func fetchUserInfo(handle: String) async throws -> CFUser
    func fetchRatingHistory(handle: String) async throws -> [CFRatingChange]
    func fetchRecentSubmissions(handle: String, count: Int) async throws -> [CFSubmission]
    func fetchUpcomingContests() async throws -> [CFContest]
}

// MARK: - Implementation

final class CodeforcesService: CodeforcesServiceProtocol {
    private let client: APIClient
    private let cache: CacheManager

    init(client: APIClient = .shared, cache: CacheManager = .shared) {
        self.client = client
        self.cache = cache
    }

    func fetchUserInfo(handle: String) async throws -> CFUser {
        let cacheKey = "cf_user_\(handle)"
        if let cached: CFUser = cache.get(cacheKey) { return cached }

        guard let url = CFEndpoints.userInfo(handles: [handle]) else {
            throw APIError.invalidURL
        }

        let response: CFResponse<[CFUser]> = try await client.request(url: url)

        guard response.status == "OK", let user = response.result?.first else {
            throw APIError.invalidResponse
        }

        cache.set(cacheKey, value: user)
        return user
    }

    func fetchRatingHistory(handle: String) async throws -> [CFRatingChange] {
        guard let url = CFEndpoints.userRating(handle: handle) else {
            throw APIError.invalidURL
        }

        let response: CFResponse<[CFRatingChange]> = try await client.request(url: url)

        guard response.status == "OK" else {
            throw APIError.invalidResponse
        }

        return response.result ?? []
    }

    func fetchRecentSubmissions(handle: String, count: Int = 30) async throws -> [CFSubmission] {
        guard let url = CFEndpoints.userStatus(handle: handle, count: count) else {
            throw APIError.invalidURL
        }

        let response: CFResponse<[CFSubmission]> = try await client.request(url: url)

        guard response.status == "OK" else {
            throw APIError.invalidResponse
        }

        return response.result ?? []
    }

    func fetchUpcomingContests() async throws -> [CFContest] {
        guard let url = CFEndpoints.contestList() else {
            throw APIError.invalidURL
        }

        let response: CFResponse<[CFContest]> = try await client.request(url: url)

        guard response.status == "OK" else {
            throw APIError.invalidResponse
        }

        return (response.result ?? []).filter { $0.isUpcoming }.sorted {
            ($0.startTimeSeconds ?? 0) < ($1.startTimeSeconds ?? 0)
        }
    }
}

// MARK: - Mock for Previews

final class MockCodeforcesService: CodeforcesServiceProtocol {
    func fetchUserInfo(handle: String) async throws -> CFUser {
        CFUser(
            handle: "demo_cf", rating: 1450, maxRating: 1600,
            rank: "specialist", maxRank: "expert",
            avatar: nil, titlePhoto: nil,
            firstName: "Demo", lastName: "User",
            country: "India", organization: nil,
            contribution: 10, registrationTimeSeconds: 1600000000,
            friendOfCount: 25
        )
    }

    func fetchRatingHistory(handle: String) async throws -> [CFRatingChange] { [] }
    func fetchRecentSubmissions(handle: String, count: Int) async throws -> [CFSubmission] { [] }
    func fetchUpcomingContests() async throws -> [CFContest] { [] }
}
