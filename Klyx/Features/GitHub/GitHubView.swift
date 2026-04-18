import SwiftUI
import SwiftData

/// GitHub profile tab — Box Box massive typography aesthetic.
struct GitHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var viewModel = GitHubViewModel()

    private var userProfile: UserProfile? { profiles.first }

    /// Re-triggers `.task(id:)` when GitHub username changes.
    private var ghFingerprint: String {
        profiles.first?.githubUsername ?? ""
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.pureBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // MARK: - Hero Header
                        HStack {
                            Text("GITHUB")
                                .clash(size: 38, weight: .bold)
                                .foregroundStyle(.white)
                                .tracking(2)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        
                        // MARK: - Profile Header
                        if let profile = viewModel.profile {
                            profileHeader(profile)
                        }

                        // MARK: - Streak Cards
                        streakCards

                        // MARK: - Contribution Heatmap
                        if let calendar = viewModel.contributionCalendar {
                            BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("CONTRIBUTIONS")
                                        .clash(size: 18, weight: .bold)
                                        .foregroundStyle(AppColors.boxGreen)
                                        .tracking(1)
                                    ContributionHeatmapView(calendar: calendar)
                                }
                            }
                        }

                        // MARK: - Top Repos
                        if !viewModel.repos.isEmpty {
                            reposSection
                        }

                        // MARK: - Error
                        if let error = viewModel.errorMessage {
                            BentoCard(backgroundColor: AppColors.boxRed, cornerRadius: 24) {
                                Text(error.uppercased())
                                    .clash(size: 14, weight: .bold)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .refreshable {
                await loadData()
            }
            .task(id: ghFingerprint) {
                await loadData()
            }
            .overlay {
                if viewModel.isLoading && viewModel.profile == nil {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppColors.pureBlack.opacity(0.8))
                }

                if !viewModel.isLoading && viewModel.profile == nil && ghFingerprint.isEmpty {
                    ContentUnavailableView(
                        "No GitHub Account",
                        systemImage: "arrow.triangle.branch",
                        description: Text("Add your GitHub username in Settings to see your contributions.")
                    )
                }
            }
        }
    }

    // MARK: - Subviews

    private func profileHeader(_ profile: GHUser) -> some View {
        BentoCard(backgroundColor: AppColors.boxGreen, cornerRadius: 36) {
            HStack(spacing: 16) {
                if let avatar = profile.avatarUrl, let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(AppColors.pureBlack.opacity(0.2))
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.black, lineWidth: 4))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text((profile.name ?? profile.login).uppercased())
                        .clash(size: 28, weight: .bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    if let bio = profile.bio, !bio.isEmpty {
                        Text(bio.uppercased())
                            .clash(size: 12, weight: .bold)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(2)
                    }

                    HStack(spacing: 16) {
                        Label("\(profile.followers)", systemImage: "person.2.fill")
                        Label("\(profile.publicRepos)", systemImage: "folder.fill")
                        Label("\(viewModel.totalStars)", systemImage: "star.fill")
                    }
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white)
                    .padding(.top, 4)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(height: 140)
    }

    private var streakCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "CURRENT",
                value: "\(viewModel.currentStreak)",
                subtitle: "DAYS",
                icon: "flame.fill",
                color: AppColors.boxRed
            )

            StatCard(
                title: "LONGEST",
                value: "\(viewModel.longestStreak)",
                subtitle: "DAYS",
                icon: "crown.fill",
                color: AppColors.boxYellow
            )

            StatCard(
                title: "CONTRIBS",
                value: "\(viewModel.contributionCalendar?.totalContributions ?? 0)",
                subtitle: "YEAR",
                icon: "square.grid.3x3.fill",
                color: AppColors.boxBlue
            )
        }
        .frame(height: 180)
    }

    private var reposSection: some View {
        BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 24) {
                Text("TOP REPOSITORIES")
                    .clash(size: 18, weight: .bold)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(1)

                ForEach(Array(viewModel.repos.prefix(6).enumerated()), id: \.element.id) { index, repo in
                    HStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AppColors.boxGreen)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(repo.name)
                                .clash(size: 20, weight: .bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            if let desc = repo.description {
                                Text(desc.uppercased())
                                    .clash(size: 12, weight: .bold)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(spacing: 4) {
                                Text("\(repo.stargazersCount)")
                                    .clash(size: 16, weight: .bold)
                                    .foregroundStyle(.white)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppColors.boxYellow)
                            }

                            if let lang = repo.language {
                                Text(lang.uppercased())
                                    .clash(size: 10, weight: .bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.boxGreen, in: Capsule())
                            }
                        }
                    }

                    if index < min(viewModel.repos.count, 6) - 1 {
                        Divider().background(.white.opacity(0.1))
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Helpers

    private func loadData() async {
        guard let username = userProfile?.githubUsername, !username.isEmpty else { return }
        let token = KeychainManager.shared.loadString(forKey: KeychainManager.Keys.githubToken)
        await viewModel.fetchAll(username: username, token: token)
    }
}
