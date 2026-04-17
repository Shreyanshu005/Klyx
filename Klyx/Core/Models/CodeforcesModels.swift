//
//  CodeforcesModels.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

// MARK: - Generic CF Response Wrapper

struct CFResponse<T: Decodable>: Decodable {
    let status: String        // "OK" or "FAILED"
    let result: T?
    let comment: String?      // error message when status == "FAILED"
}

// MARK: - User Info

struct CFUser: Decodable, Identifiable {
    var id: String { handle }
    let handle: String
    let rating: Int?
    let maxRating: Int?
    let rank: String?
    let maxRank: String?
    let avatar: String?
    let titlePhoto: String?
    let firstName: String?
    let lastName: String?
    let country: String?
    let organization: String?
    let contribution: Int?
    let registrationTimeSeconds: Int?
    let friendOfCount: Int?

    var displayName: String {
        [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
}

// MARK: - Rating Change (Contest History)

struct CFRatingChange: Decodable, Identifiable {
    var id: Int { ratingUpdateTimeSeconds }
    let contestId: Int
    let contestName: String
    let handle: String
    let rank: Int
    let ratingUpdateTimeSeconds: Int
    let oldRating: Int
    let newRating: Int

    var ratingDelta: Int { newRating - oldRating }

    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(ratingUpdateTimeSeconds))
    }
}

// MARK: - Submission

struct CFSubmission: Decodable, Identifiable {
    let id: Int
    let contestId: Int?
    let creationTimeSeconds: Int
    let problem: CFProblem
    let programmingLanguage: String
    let verdict: String?
    let passedTestCount: Int?

    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(creationTimeSeconds))
    }

    var isAccepted: Bool { verdict == "OK" }
}

struct CFProblem: Decodable {
    let contestId: Int?
    let index: String
    let name: String
    let rating: Int?
    let tags: [String]?

    var displayName: String {
        if let contestId {
            return "\(contestId)\(index) — \(name)"
        }
        return "\(index) — \(name)"
    }
}

// MARK: - Contest

struct CFContest: Decodable, Identifiable {
    let id: Int
    let name: String
    let type: String                // "CF", "IOI", "ICPC"
    let phase: String               // "BEFORE", "CODING", "FINISHED"
    let durationSeconds: Int
    let startTimeSeconds: Int?
    let relativeTimeSeconds: Int?

    var startDate: Date? {
        guard let startTimeSeconds else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(startTimeSeconds))
    }

    var isUpcoming: Bool { phase == "BEFORE" }
}
