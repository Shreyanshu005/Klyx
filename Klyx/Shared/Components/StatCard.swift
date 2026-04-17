//
//  StatCard.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// Flat, solid Box Box style mini card used throughout the app for stat lists.
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)

            Spacer()

            Text(value)
                .clash(size: 38, weight: .bold)
                .foregroundStyle(.white)
                .tracking(-1)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white)
                    .tracking(1)

                Text(subtitle)
                    .clash(size: 12, weight: .bold)
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    HStack {
        StatCard(
            title: "Current Streak",
            value: "14",
            subtitle: "Days",
            icon: "flame.fill",
            color: AppColors.boxRed
        )
        .frame(width: 140, height: 140)
        
        StatCard(
            title: "Contributions",
            value: "2,351",
            subtitle: "This Year",
            icon: "square.grid.3x3.fill",
            color: AppColors.boxGreen
        )
        .frame(width: 140, height: 140)
    }
    .padding()
    .background(Color.black)
}
