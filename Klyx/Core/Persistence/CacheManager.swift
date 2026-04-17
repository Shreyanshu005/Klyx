//
//  CacheManager.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import Foundation

/// Lightweight cache manager using UserDefaults (App Group) for widget-sharable data
/// and in-memory cache for the main app session.
final class CacheManager {
    static let shared = CacheManager()

    /// App Group UserDefaults — shared with widget extension.
    private let defaults: UserDefaults

    /// In-memory cache for the current app session.
    private var memoryCache: [String: (data: Any, expiry: Date)] = [:]

    /// Default cache TTL: 15 minutes.
    private let defaultTTL: TimeInterval = 15 * 60

    init() {
        self.defaults = UserDefaults(suiteName: "group.com.shreyanshu.klyx") ?? .standard
    }

    // MARK: - Memory Cache

    func get<T>(_ key: String) -> T? {
        guard let entry = memoryCache[key],
              entry.expiry > .now,
              let value = entry.data as? T else {
            memoryCache.removeValue(forKey: key)
            return nil
        }
        return value
    }

    func set<T>(_ key: String, value: T, ttl: TimeInterval? = nil) {
        let expiry = Date.now.addingTimeInterval(ttl ?? defaultTTL)
        memoryCache[key] = (data: value, expiry: expiry)
    }

    // MARK: - Persistent Cache (UserDefaults / App Group)

    func persistCodable<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func loadCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    func remove(forKey key: String) {
        memoryCache.removeValue(forKey: key)
        defaults.removeObject(forKey: key)
    }

    // MARK: - Cache Keys

    enum Keys {
        static let devScore = "cached_dev_score"
        static let lcProfile = "cached_lc_profile"
        static let ghProfile = "cached_gh_profile"
        static let cfProfile = "cached_cf_profile"
        static let lastSyncDate = "last_sync_date"
    }
}
