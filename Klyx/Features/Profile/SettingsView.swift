//
//  SettingsView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import SwiftData

/// Settings screen — manage accounts, cache, appearance, and about.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showProfileSetup = false
    @State private var showClearCacheAlert = false

    @AppStorage("appearance") private var appearance: AppAppearance = .system
    @AppStorage("haptics_enabled") private var hapticsEnabled = true
    @AppStorage("widget_auto_refresh") private var widgetAutoRefresh = true

    private var userProfile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Accounts
                Section("Connected Accounts") {
                    accountRow(platform: "LeetCode", username: userProfile?.leetcodeUsername, icon: "chevron.left.forwardslash.chevron.right", color: AppColors.boxYellow)
                    accountRow(platform: "GitHub", username: userProfile?.githubUsername, icon: "arrow.triangle.branch", color: AppColors.boxGreen)
                    accountRow(platform: "Codeforces", username: userProfile?.codeforcesHandle, icon: "trophy", color: AppColors.boxBlue)

                    Button("Edit Accounts") {
                        showProfileSetup = true
                    }
                }

                // MARK: - Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }

                    Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                }

                // MARK: - Widget
                Section("Widget") {
                    Toggle("Auto-Refresh", isOn: $widgetAutoRefresh)
                    Text("Widgets refresh every 30 minutes when enabled.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Data
                Section("Data") {
                    Button("Clear Cache", role: .destructive) {
                        showClearCacheAlert = true
                    }

                    if let lastSync = userProfile?.lastSyncDate {
                        HStack {
                            Text("Last Synced")
                            Spacer()
                            Text(lastSync.shortFormatted)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // MARK: - About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    Link("Source Code", destination: URL(string: "https://github.com/shreyanshu/klyx")!)
                    Link("Report a Bug", destination: URL(string: "https://github.com/shreyanshu/klyx/issues")!)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showProfileSetup) {
                ProfileSetupView()
            }
            .alert("Clear Cache?", isPresented: $showClearCacheAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    CacheManager.shared.remove(forKey: CacheManager.Keys.devScore)
                    CacheManager.shared.remove(forKey: CacheManager.Keys.lcProfile)
                    CacheManager.shared.remove(forKey: CacheManager.Keys.ghProfile)
                    CacheManager.shared.remove(forKey: CacheManager.Keys.cfProfile)
                }
            } message: {
                Text("This will remove all cached data. Your accounts will not be affected.")
            }
        }
    }

    private func accountRow(platform: String, username: String?, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(platform)

            Spacer()

            Text(username ?? "Not connected")
                .foregroundStyle(username != nil ? .primary : .secondary)
        }
    }
}

// MARK: - Appearance Enum

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
