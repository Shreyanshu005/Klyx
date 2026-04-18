import SwiftUI
import SwiftData

/// Onboarding / profile setup — user enters their platform usernames.
struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Environment(\.dismiss) private var dismiss

    @State private var lcUsername = ""
    @State private var ghUsername = ""
    @State private var ghToken = ""
    @State private var cfHandle = ""
    @State private var isSaving = false

    private var existingProfile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            AppColors.pureBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CONNECT")
                            .clash(size: 44, weight: .bold)
                            .foregroundStyle(.white)
                            .tracking(2)
                        Text("YOUR STACK")
                            .clash(size: 44, weight: .bold)
                            .foregroundStyle(AppColors.boxYellow)
                            .tracking(2)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // MARK: - LeetCode
                    setupSection(title: "LEETCODE", color: AppColors.boxYellow) {
                        VStack(spacing: 12) {
                            brutalistTextField("Username", text: $lcUsername, icon: "person.fill")
                        }
                    }

                    // MARK: - GitHub
                    setupSection(title: "GITHUB", color: AppColors.boxGreen) {
                        VStack(spacing: 16) {
                            brutalistTextField("Username", text: $ghUsername, icon: "person.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                brutalistSecureField("Personal Access Token", text: $ghToken, icon: "key.fill")
                                Text("Required for contribution data. Create at GitHub → Settings → Developer Settings → Tokens.")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(.horizontal, 4)
                            }
                        }
                    }

                    // MARK: - Codeforces
                    setupSection(title: "CODEFORCES", color: AppColors.boxBlue) {
                        brutalistTextField("Handle", text: $cfHandle, icon: "person.fill")
                    }

                    // MARK: - Save Button
                    Button {
                        saveProfile()
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("INITIALIZE PROFILE")
                                    .clash(size: 18, weight: .bold)
                                    .foregroundStyle(.black)
                                    .tracking(1)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 24)
                        .background(AppColors.boxYellow, in: RoundedRectangle(cornerRadius: 24))
                    }
                    .disabled(lcUsername.isEmpty && ghUsername.isEmpty && cfHandle.isEmpty)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            if let profile = existingProfile {
                lcUsername = profile.leetcodeUsername ?? ""
                ghUsername = profile.githubUsername ?? ""
                cfHandle = profile.codeforcesHandle ?? ""
                ghToken = KeychainManager.shared.loadString(forKey: KeychainManager.Keys.githubToken) ?? ""
            }
        }
    }

    private func setupSection<Content: View>(title: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .clash(size: 14, weight: .bold)
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1)
            
            BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
                content()
            }
        }
    }

    private func brutalistTextField(_ placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.4))
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.2)))
                .clash(size: 16, weight: .bold)
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func brutalistSecureField(_ placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.4))
            SecureField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.2)))
                .clash(size: 16, weight: .bold)
                .foregroundStyle(.white)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func saveProfile() {
        isSaving = true

        let profile = existingProfile ?? UserProfile()
        profile.leetcodeUsername = lcUsername.isEmpty ? nil : lcUsername
        profile.githubUsername = ghUsername.isEmpty ? nil : ghUsername
        profile.codeforcesHandle = cfHandle.isEmpty ? nil : cfHandle

        if existingProfile == nil {
            modelContext.insert(profile)
        }

        if !ghToken.isEmpty {
            KeychainManager.shared.save(ghToken, forKey: KeychainManager.Keys.githubToken)
        }

        try? modelContext.save()

        isSaving = false
        dismiss()
    }
}

#Preview {
    ProfileSetupView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
