//
//  GitHubModels.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

// MARK: - REST User Profile

struct GHUser: Decodable, Identifiable {
    let id: Int
    let login: String
    let name: String?
    let avatarUrl: String?
    let bio: String?
    let publicRepos: Int
    let publicGists: Int
    let followers: Int
    let following: Int
    let createdAt: Date?
    let htmlUrl: String?
}

// MARK: - Repository

struct GHRepo: Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let language: String?
    let updatedAt: Date?
    let htmlUrl: String?
}

// MARK: - GraphQL Contribution Calendar

struct GHGraphQLResponse: Decodable {
    let data: GHGraphQLData
}

struct GHGraphQLData: Decodable {
    let user: GHGraphQLUser
}

struct GHGraphQLUser: Decodable {
    let contributionsCollection: GHContributionsCollection
    let repositories: GHRepoConnection?
}

struct GHContributionsCollection: Decodable {
    let contributionCalendar: GHContributionCalendar
}

struct GHContributionCalendar: Decodable {
    let totalContributions: Int
    let weeks: [GHContributionWeek]
}

struct GHContributionWeek: Decodable {
    let contributionDays: [GHContributionDay]
}

struct GHContributionDay: Decodable, Identifiable {
    var id: String { date }
    let contributionCount: Int
    let date: String          // "2025-04-17"
    let color: String         // hex, e.g. "#216e39"
}

struct GHRepoConnection: Decodable {
    let nodes: [GHRepoNode]
}

struct GHRepoNode: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let description: String?
    let stargazerCount: Int
    let forkCount: Int
    let primaryLanguage: GHLanguage?
    let updatedAt: String?
    let url: String
}

struct GHLanguage: Decodable {
    let name: String
    let color: String?
}

// MARK: - Public Events

struct GHEvent: Decodable, Identifiable {
    let id: String
    let type: String
    let createdAt: Date?
    let repo: GHEventRepo

    struct GHEventRepo: Decodable {
        let name: String
    }
}
