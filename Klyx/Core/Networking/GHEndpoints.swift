//
//  GHEndpoints.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

/// GitHub API endpoints — uses REST v3 and GraphQL v4.
enum GHEndpoints {
    static let restBase = "https://api.github.com"
    static let graphQLURL = URL(string: "https://api.github.com/graphql")!

    // MARK: - REST Endpoints

    /// GET /users/{username}
    static func userProfile(username: String) -> URL? {
        URL(string: "\(restBase)/users/\(username)")
    }

    /// GET /users/{username}/repos — sorted by updated
    static func userRepos(username: String, page: Int = 1, perPage: Int = 30) -> URL? {
        URL(string: "\(restBase)/users/\(username)/repos?sort=updated&per_page=\(perPage)&page=\(page)")
    }

    /// GET /users/{username}/events/public
    static func userEvents(username: String, page: Int = 1) -> URL? {
        URL(string: "\(restBase)/users/\(username)/events/public?per_page=30&page=\(page)")
    }

    // MARK: - GraphQL Query (Contribution Calendar)

    /// Fetches the contribution calendar heatmap for the past year.
    static let contributionCalendarQuery = """
    query($username: String!) {
        user(login: $username) {
            contributionsCollection {
                contributionCalendar {
                    totalContributions
                    weeks {
                        contributionDays {
                            contributionCount
                            date
                            color
                        }
                    }
                }
            }
            repositories(first: 10, orderBy: {field: UPDATED_AT, direction: DESC}) {
                nodes {
                    name
                    description
                    stargazerCount
                    forkCount
                    primaryLanguage {
                        name
                        color
                    }
                    updatedAt
                    url
                }
            }
        }
    }
    """

    // MARK: - Auth Headers

    /// Standard authorization header for GitHub API.
    static func authHeaders(token: String) -> [String: String] {
        [
            "Authorization": "Bearer \(token)",
            "Accept": "application/vnd.github.v3+json"
        ]
    }
}
