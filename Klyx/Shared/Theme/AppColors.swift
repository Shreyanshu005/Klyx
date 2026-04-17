//
//  AppColors.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// Centralized color palette for the entire app.
/// All views reference these instead of using ad-hoc colors.
enum AppColors {
    // MARK: - Primary Gradient
    // Kept for fallback, but transitioning away from gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#00F0FF"), Color(hex: "#B026FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Box Box Flat Colors
    static let boxRed = Color(hex: "#FF2323")      // Vibrant Red
    static let boxYellow = Color(hex: "#E0FF00")   // Neon/Electric Yellow
    static let boxBlue = Color(hex: "#303CFF")     // Indigo/Blue
    static let boxGreen = Color(hex: "#00D166")    // Bright Mint Green
    
    // MARK: - Background Colors
    static let pureBlack = Color(hex: "#000000")
    static let cardBackground = Color(hex: "#101010")  // Very dark gray for neutral cards
    static let surfaceBackground = Color(hex: "#1A1A1A")

    // MARK: - Semantic
    static let success = Color(hex: "#39FF14")
    static let warning = Color(hex: "#FFEA00")
    static let error = Color(hex: "#FF003C")

    // MARK: - Codeforces Rating Colors
    static func cfRatingColor(_ rating: Int) -> Color {
        switch rating {
        case ..<1200:      return .gray
        case 1200..<1400:  return .green
        case 1400..<1600:  return .cyan
        case 1600..<1900:  return Color(hex: "#4A90D9")
        case 1900..<2100:  return .purple
        case 2100..<2400:  return .orange
        case 2400..<2600:  return .red
        default:           return Color(hex: "#AA0000")
        }
    }

    // MARK: - Gradients
    static let fireGradient = LinearGradient(
        colors: [.orange, .red],
        startPoint: .top,
        endPoint: .bottom
    )

    static let streakGradient = LinearGradient(
        colors: [Color(hex: "#FF512F"), Color(hex: "#DD2476")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let githubGradient = LinearGradient(
        colors: [Color(hex: "#0e4429"), Color(hex: "#39d353")],
        startPoint: .leading,
        endPoint: .trailing
    )
}
