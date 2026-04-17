//
//  SocialView.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI
import SwiftData

/// Dynamic Leaderboard featuring Box Box aesthetic and Clash Display.
struct SocialView: View {
    @Query(sort: \FriendProfile.dateAdded) private var savedProfiles: [FriendProfile]
    @State private var viewModel = SocialViewModel()
    @State private var showAddFriend = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.pureBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // Header Box
                        BentoCard(backgroundColor: AppColors.boxBlue, cornerRadius: 28) {
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("LIVE")
                                        .clash(size: 16, weight: .bold)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .tracking(1)
                                    Text("LEADERBOARD")
                                        .clash(size: 38, weight: .bold)
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                Button {
                                    showAddFriend = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundStyle(AppColors.boxBlue)
                                        .padding(16)
                                        .background(.white, in: Circle())
                                }
                            }
                        }
                        .frame(height: 140)

                        if savedProfiles.isEmpty {
                            BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 24) {
                                VStack(spacing: 16) {
                                    Image(systemName: "person.2.slash.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.white.opacity(0.5))
                                    Text("NO FRIENDS TRACKED")
                                        .clash(size: 18, weight: .bold)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 40)
                            }
                        } else if viewModel.isLoading {
                            BentoCard(backgroundColor: AppColors.cardBackground, cornerRadius: 24) {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .tint(AppColors.boxYellow)
                                        .scaleEffect(1.8)
                                    Text("FETCHING LIVE SCORES")
                                        .clash(size: 14, weight: .bold)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .tracking(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 40)
                            }
                        } else {
                            // Leaderboard Feed
                            ForEach(viewModel.leaderboard) { entry in
                                NavigationLink(destination: FriendDetailView(friend: entry.alias, score: entry.devScore)) {
                                    BentoCard(backgroundColor: entry.rank == 1 ? AppColors.boxYellow : AppColors.cardBackground, cornerRadius: 28) {
                                        HStack(spacing: 16) {
                                            Text("#\(entry.rank)")
                                                .clash(size: 42, weight: .bold)
                                                .foregroundStyle(entry.rank == 1 ? .black : .white.opacity(0.3))
                                                .minimumScaleFactor(0.5)
                                                .lineLimit(1)
                                            
                                            VStack(alignment: .leading, spacing: -2) {
                                                Text(entry.alias.uppercased())
                                                    .clash(size: 24, weight: .bold)
                                                    .foregroundStyle(entry.rank == 1 ? .black : .white)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                
                                                Text(entry.devScore.tier.uppercased())
                                                    .clash(size: 12, weight: .bold)
                                                    .foregroundStyle(entry.rank == 1 ? .black.opacity(0.6) : AppColors.boxGreen)
                                            }

                                            Spacer()

                                            Text("\(entry.devScore.compositeScore)")
                                                .clash(size: 48, weight: .bold)
                                                .foregroundStyle(entry.rank == 1 ? .black : .white)
                                                .tracking(-3)
                                                .minimumScaleFactor(0.5)
                                                .lineLimit(1)
                                        }
                                    }
                                    .frame(height: 110)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddFriend) {
                AddFriendView()
            }
            .task(id: savedProfiles.count) {
                if !savedProfiles.isEmpty {
                    await viewModel.loadFriends(profiles: savedProfiles)
                }
            }
            .refreshable {
                await viewModel.loadFriends(profiles: savedProfiles)
            }
        }
    }
}
