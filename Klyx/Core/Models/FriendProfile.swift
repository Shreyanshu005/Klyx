import Foundation
import SwiftData

/// Represents a tracked friend's platform usernames for dynamic DevScore computation.
@Model
final class FriendProfile {
    var id: UUID
    var alias: String
    var leetcodeUsername: String?
    var githubUsername: String?
    var codeforcesHandle: String?
    var dateAdded: Date
    
    init(alias: String, leetcodeUsername: String? = nil, githubUsername: String? = nil, codeforcesHandle: String? = nil) {
        self.id = UUID()
        self.alias = alias
        self.leetcodeUsername = leetcodeUsername
        self.githubUsername = githubUsername
        self.codeforcesHandle = codeforcesHandle
        self.dateAdded = Date.now
    }
}
