import SwiftUI

/// Centralized color palette for the entire app.
/// All views reference these instead of using ad-hoc colors.
enum AppColors {
    // MARK: - Box Box Flat Colors
    static let boxRed = Color(hex: "#F5191D")
    static let textRedShade = Color(hex: "#FE7679")
    static let boxYellow = Color(hex: "#FFDA27")
    static let boxBlue = Color(hex: "#2F1FFD")
    static let boxGreen = Color(hex: "#02BB81")
    
    // MARK: - Background Colors
    static let pureBlack = Color(hex: "#000000")
    static let cardBackground = Color(hex: "#101010")
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
}
