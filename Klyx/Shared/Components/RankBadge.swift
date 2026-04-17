//
//  RankBadge.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// Flat, solid Box Box style pill used to display platform ranks.
struct RankBadge: View {
    let rank: String
    let platform: Platform

    enum Platform {
        case leetcode, codeforces
    }

    var body: some View {
        Text(rank.uppercased())
            .clash(size: 14, weight: .bold)
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch platform {
        case .leetcode:
            return AppColors.boxYellow
        case .codeforces:
            return AppColors.cfRatingColor(numericRatingForPlatformRank)
        }
    }

    // Heuristic strictly for getting the color based on the named rank.
    private var numericRatingForPlatformRank: Int {
        if platform == .leetcode { return .zero }
        switch rank.lowercased() {
        case "newbie": return 0
        case "pupil": return 1200
        case "specialist": return 1400
        case "expert": return 1600
        case "candidate master": return 1900
        case "master", "international master": return 2100
        case "grandmaster", "international grandmaster": return 2400
        case "legendary grandmaster": return 2600
        default: return .zero
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        RankBadge(rank: "pupil", platform: .codeforces)
        RankBadge(rank: "specialist", platform: .codeforces)
        RankBadge(rank: "expert", platform: .codeforces)
        RankBadge(rank: "grandmaster", platform: .codeforces)
        RankBadge(rank: "Knight", platform: .leetcode)
    }
    .padding()
    .background(Color.black)
}
