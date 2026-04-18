import Foundation

extension Date {
    /// "Apr 17, 2026"
    var shortFormatted: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }

    /// "2 hours ago", "3 days ago", etc.
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: .now)
    }

    /// "2026-04-17" — ISO date string (no time).
    var isoDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: self)
    }

    /// Start of day (midnight).
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Number of days between this date and another.
    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startOfDay, to: other.startOfDay)
        return abs(components.day ?? 0)
    }

    /// Returns an array of dates for the past N days (including today).
    static func pastDays(_ count: Int) -> [Date] {
        (0..<count).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: .now)?.startOfDay
        }.reversed()
    }
}
