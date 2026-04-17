//
//  RootView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import SwiftData

/// Root TabView with 5 tabs — the main navigation structure of the app.
struct RootView: View {
    @Query private var profiles: [UserProfile]
    @State private var selectedTab: Tab = .dashboard
    @State private var showOnboarding = false

    @State private var competitiveVM = CompetitiveViewModel()
    @State private var socialVM = SocialViewModel()

    /// Re-triggers `.task(id:)` when profile changes.
    private var profileFingerprint: String {
        let p = profiles.first
        return [p?.leetcodeUsername, p?.githubUsername, p?.codeforcesHandle]
            .compactMap { $0 }
            .joined(separator: "|")
    }

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case competitive = "Competitive"
        case github = "GitHub"
        case social = "Social"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "chart.bar.fill"
            case .competitive: return "trophy.fill"
            case .github: return "square.stack.3d.up.fill"
            case .social: return "person.2.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Dashboard Tab
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)

            // MARK: - Competitive Tab
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Massive Switcher
                        HStack(spacing: 12) {
                            competitiveTabButton(title: "LEETCODE", tab: .leetcode, color: AppColors.boxYellow)
                            competitiveTabButton(title: "CODEFORCES", tab: .codeforces, color: AppColors.boxBlue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                        // Content
                        switch competitiveVM.selectedTab {
                        case .leetcode:
                            LeetCodeView(viewModel: competitiveVM)
                        case .codeforces:
                            CodeforcesView(viewModel: competitiveVM)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .task(id: profileFingerprint) {
                    if let lc = profiles.first?.leetcodeUsername {
                        await competitiveVM.fetchLeetCode(username: lc)
                    }
                    if let cf = profiles.first?.codeforcesHandle {
                        await competitiveVM.fetchCodeforces(handle: cf)
                    }
                }
                .refreshable {
                    if let lc = profiles.first?.leetcodeUsername {
                        await competitiveVM.fetchLeetCode(username: lc)
                    }
                    if let cf = profiles.first?.codeforcesHandle {
                        await competitiveVM.fetchCodeforces(handle: cf)
                    }
                }
            }
            .tabItem {
                Image(systemName: Tab.competitive.icon)
            }
            .tag(Tab.competitive)

            // MARK: - GitHub Tab
            GitHubView()
                .tabItem {
                    Image(systemName: Tab.github.icon)
                }
                .tag(Tab.github)

            // MARK: - Social Tab
            SocialView()
                .tabItem {
                    Image(systemName: Tab.social.icon)
                }
                .tag(Tab.social)

            // MARK: - Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.boxGreen)
        .preferredColorScheme(.dark)
        .onAppear {
            // Show onboarding if no profile exists
            if profiles.isEmpty {
                showOnboarding = true
            }
        }
        .sheet(isPresented: $showOnboarding) {
            ProfileSetupView()
                .interactiveDismissDisabled(profiles.isEmpty)
        }
    }

    // MARK: - Helpers

    private func competitiveTabButton(title: String, tab: CompetitiveViewModel.CompetitiveTab, color: Color) -> some View {
        let isSelected = competitiveVM.selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                competitiveVM.selectedTab = tab
            }
        } label: {
            Text(title)
                .clash(size: 14, weight: .bold)
                .foregroundStyle(isSelected ? (tab == .leetcode ? .black : .white) : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? color : AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
