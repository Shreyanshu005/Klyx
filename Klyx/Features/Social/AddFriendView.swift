//
//  AddFriendView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import SwiftData

/// Add Friend Modal — Box Box Aesthetic.
struct AddFriendView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var alias = ""
    @State private var lcUsername = ""
    @State private var ghUsername = ""
    @State private var cfHandle = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.pureBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 28) {
                            VStack(alignment: .leading, spacing: 24) {
                                Text("TRACK FRIEND")
                                    .clash(size: 28, weight: .bold)
                                    .foregroundStyle(.white)
                                    .tracking(1)

                                inputField(title: "ALIAS/NAME", text: $alias, color: .white)
                                inputField(title: "GITHUB", text: $ghUsername, color: AppColors.boxGreen)
                                inputField(title: "LEETCODE", text: $lcUsername, color: AppColors.boxYellow)
                                inputField(title: "CODEFORCES", text: $cfHandle, color: AppColors.boxBlue)
                            }
                        }

                        Button(action: saveFriend) {
                            BentoCard(backgroundColor: AppColors.boxGreen, cornerRadius: 24) {
                                HStack {
                                    Spacer()
                                    Text("ADD FRIEND")
                                        .clash(size: 18, weight: .bold)
                                        .foregroundStyle(.black)
                                        .tracking(1)
                                    Spacer()
                                }
                            }
                        }
                        .frame(height: 64)
                        .disabled(alias.isEmpty)
                        .opacity(alias.isEmpty ? 0.5 : 1.0)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .clash(size: 16, weight: .bold)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func inputField(title: String, text: Binding<String>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .clash(size: 14, weight: .bold)
                .foregroundStyle(color)
                .tracking(1)

            TextField("", text: text)
                .clash(size: 18, weight: .bold)
                .foregroundStyle(.white)
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
    }

    private func saveFriend() {
        let friend = FriendProfile(
            alias: alias,
            leetcodeUsername: lcUsername.isEmpty ? nil : lcUsername,
            githubUsername: ghUsername.isEmpty ? nil : ghUsername,
            codeforcesHandle: cfHandle.isEmpty ? nil : cfHandle
        )
        modelContext.insert(friend)
        try? modelContext.save()
        dismiss()
    }
}
