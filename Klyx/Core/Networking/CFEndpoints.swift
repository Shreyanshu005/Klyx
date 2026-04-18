import Foundation

/// Codeforces API endpoints — uses their public REST API.
enum CFEndpoints {
    static let baseURL = "https://codeforces.com/api"

    /// GET user.info — basic user details & rating.
    static func userInfo(handles: [String]) -> URL? {
        let joined = handles.joined(separator: ";")
        return URL(string: "\(baseURL)/user.info?handles=\(joined)")
    }

    /// GET user.rating — contest rating history.
    static func userRating(handle: String) -> URL? {
        URL(string: "\(baseURL)/user.rating?handle=\(handle)")
    }

    /// GET user.status — recent submissions.
    static func userStatus(handle: String, from: Int = 1, count: Int = 30) -> URL? {
        URL(string: "\(baseURL)/user.status?handle=\(handle)&from=\(from)&count=\(count)")
    }

    /// GET contest.list — upcoming and past contests.
    static func contestList(gym: Bool = false) -> URL? {
        URL(string: "\(baseURL)/contest.list?gym=\(gym)")
    }
}
