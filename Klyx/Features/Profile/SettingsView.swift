import SwiftUI
import SwiftData

/// Settings screen — manage accounts, cache, appearance, and about.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showProfileSetup = false
    @State private var showClearCacheAlert = false

    @AppStorage("haptics_enabled") private var hapticsEnabled = true
    @AppStorage("widget_auto_refresh") private var widgetAutoRefresh = true

    private var userProfile: UserProfile? { profiles.first }

    @State private var showLogoutSuccess = false

    var body: some View {
        ZStack {
            AppColors.pureBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Header
                    Text("SETTINGS")
                        .clash(size: 32, weight: .bold)
                        .foregroundStyle(.white)
                        .tracking(2)
                        .padding(.top, 20)

                    // MARK: - Accounts
                    settingsSection(title: "CONNECTED ACCOUNTS") {
                        VStack(spacing: 16) {
                            accountRow(platform: "LeetCode", username: userProfile?.leetcodeUsername, icon: "chevron.left.forwardslash.chevron.right", color: AppColors.boxYellow)
                            accountRow(platform: "GitHub", username: userProfile?.githubUsername, icon: "square.stack.3d.up.fill", color: AppColors.boxGreen)
                            accountRow(platform: "Codeforces", username: userProfile?.codeforcesHandle, icon: "trophy", color: AppColors.boxBlue)
                            
                            Button {
                                showProfileSetup = true
                            } label: {
                                HStack {
                                    Text("EDIT ACCOUNTS")
                                        .clash(size: 14, weight: .bold)
                                    Spacer()
                                    Image(systemName: "pencil.and.outline")
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    // MARK: - Options
                    settingsSection(title: "CONFIGURATION") {
                        VStack(spacing: 16) {
                            Toggle(isOn: $hapticsEnabled) {
                                Text("HAPTIC FEEDBACK")
                                    .clash(size: 14, weight: .bold)
                            }
                            .tint(AppColors.boxGreen)
                        }
                    }

                    // MARK: - Data
                    settingsSection(title: "DATA & SYSTEM") {
                        VStack(spacing: 16) {
                            Button(role: .destructive) {
                                showClearCacheAlert = true
                            } label: {
                                HStack {
                                    Text("CLEAR CACHE")
                                        .clash(size: 14, weight: .bold)
                                    Spacer()
                                    Image(systemName: "trash.fill")
                                }
                            }
                            
                            HStack {
                                Text("VERSION")
                                    .clash(size: 14, weight: .bold)
                                Spacer()
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                    .clash(size: 14, weight: .bold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // MARK: - Logout
                    Section {
                        Button(role: .destructive) {
                            performLogout()
                        } label: {
                            HStack {
                                Spacer()
                                Text("LOG OUT")
                                    .clash(size: 18, weight: .bold)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundStyle(.white)
                                    .padding(.trailing, 12)
                            }
                            .padding(.vertical, 20)
                            .background(AppColors.boxRed, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showProfileSetup) {
            ProfileSetupView()
        }
        .alert("Clear Cache?", isPresented: $showClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                CacheManager.shared.remove(forKey: CacheManager.Keys.aggregatedStats)
                CacheManager.shared.remove(forKey: CacheManager.Keys.lcProfile)
                CacheManager.shared.remove(forKey: CacheManager.Keys.ghProfile)
                CacheManager.shared.remove(forKey: CacheManager.Keys.cfProfile)
            }
        } message: {
            Text("This will remove all cached data. Your accounts will not be affected.")
        }
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .clash(size: 12, weight: .bold)
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1)
            
            BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 24) {
                content()
            }
        }
    }

    private func accountRow(platform: String, username: String?, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(platform)
                .clash(size: 16, weight: .bold)

            Spacer()

            Text(username ?? "Not connected")
                .clash(size: 14, weight: .bold)
                .foregroundStyle(username != nil ? .primary : .secondary)
        }
    }

    private func performLogout() {

        if let profile = userProfile {
            modelContext.delete(profile)
            try? modelContext.save()
        }

        KeychainManager.shared.delete(forKey: KeychainManager.Keys.githubToken)
        KeychainManager.shared.delete(forKey: KeychainManager.Keys.leetcodeSession)

        CacheManager.shared.remove(forKey: CacheManager.Keys.aggregatedStats)
        CacheManager.shared.remove(forKey: CacheManager.Keys.lcProfile)
        CacheManager.shared.remove(forKey: CacheManager.Keys.ghProfile)
        CacheManager.shared.remove(forKey: CacheManager.Keys.cfProfile)
        

        showLogoutSuccess = true
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
