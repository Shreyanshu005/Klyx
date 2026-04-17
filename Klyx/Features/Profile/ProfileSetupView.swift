//
//  ProfileSetupView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

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
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.primaryGradient)

                        Text("Connect Your Platforms")
                            .font(.title2.bold())

                        Text("Link your accounts to build your unified developer profile.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section("LeetCode") {
                    TextField("LeetCode Username", text: $lcUsername)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section("GitHub") {
                    TextField("GitHub Username", text: $ghUsername)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    SecureField("Personal Access Token (optional)", text: $ghToken)
                        .textContentType(.password)

                    Text("A token enables contribution heatmap and streak data. Create one at GitHub → Settings → Developer Settings → Personal Access Tokens.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Section("Codeforces") {
                    TextField("Codeforces Handle", text: $cfHandle)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section {
                    Button {
                        saveProfile()
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Save Profile")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                    }
                    .disabled(lcUsername.isEmpty && ghUsername.isEmpty && cfHandle.isEmpty)
                }
            }
            .navigationTitle("Profile Setup")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let profile = existingProfile {
                    lcUsername = profile.leetcodeUsername ?? ""
                    ghUsername = profile.githubUsername ?? ""
                    cfHandle = profile.codeforcesHandle ?? ""
                    ghToken = KeychainManager.shared.loadString(forKey: KeychainManager.Keys.githubToken) ?? ""
                }
            }
        }
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

        // Save token to Keychain
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
