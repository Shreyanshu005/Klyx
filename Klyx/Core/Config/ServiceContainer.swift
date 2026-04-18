import Foundation

/// Centralized Dependency Injection container.
///
/// `ServiceContainer` acts as the single source of truth for all service instances
/// used across the application. Instead of creating services ad-hoc, features
/// request them from this container, ensuring consistency and testability.
///
/// ## Usage
/// ```swift
/// // Production (uses real network services)
/// let container = ServiceContainer.live
///
/// // Testing (uses mock services)
/// let container = ServiceContainer.mock
/// ```
@Observable
final class ServiceContainer {
    // MARK: - Platform Services

    /// LeetCode data provider.
    let leetcode: LeetCodeServiceProtocol

    /// GitHub data provider.
    let github: GitHubServiceProtocol

    /// Codeforces data provider.
    let codeforces: CodeforcesServiceProtocol

    // MARK: - Infrastructure

    /// Shared cache manager for App Group persistence.
    let cache: CacheManager

    /// API networking client.
    let apiClient: APIClient

    // MARK: - Initialization

    /// Creates a service container with the given dependencies.
    /// - Parameters:
    ///   - apiClient: The networking client to use for all API calls.
    ///   - cache: The cache manager for persisting data to the App Group.
    ///   - leetcode: The LeetCode service implementation.
    ///   - github: The GitHub service implementation.
    ///   - codeforces: The Codeforces service implementation.
    init(
        apiClient: APIClient = .shared,
        cache: CacheManager = .shared,
        leetcode: LeetCodeServiceProtocol? = nil,
        github: GitHubServiceProtocol? = nil,
        codeforces: CodeforcesServiceProtocol? = nil
    ) {
        self.apiClient = apiClient
        self.cache = cache
        self.leetcode = leetcode ?? LeetCodeService(client: apiClient, cache: cache)
        self.github = github ?? GitHubService(client: apiClient, cache: cache)
        self.codeforces = codeforces ?? CodeforcesService(client: apiClient, cache: cache)
    }

    // MARK: - Factory Methods

    /// Production container with real network services.
    static let live = ServiceContainer()

    /// Mock container for SwiftUI previews and unit tests.
    static let mock = ServiceContainer(
        leetcode: MockLeetCodeService(),
        github: MockGitHubService(),
        codeforces: MockCodeforcesService()
    )
}
