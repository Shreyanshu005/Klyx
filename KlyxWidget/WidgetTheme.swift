//
//  WidgetTheme.swift
//  KlyxWidget
//
//  Replicated branding definitions to satisfy the KlyxWidgetExtension target.
//

import SwiftUI

// MARK: - Constants Bridge
enum Constants {
    static let appGroupID = "group.appminds.klyxx"
}

// MARK: - App Colors
enum AppColors {
    static let boxRed = Color(hex: "#F5191D")
    static let boxYellow = Color(hex: "#FFDA27")
    static let boxBlue = Color(hex: "#2F1FFD")
    static let boxGreen = Color(hex: "#02BB81")
    static let pureBlack = Color(hex: "#000000")
    static let cardBackground = Color(hex: "#101010")
}

// MARK: - Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Font Support
extension Font {
    enum ClashWeight: String {
        case bold = "ClashDisplay-Bold"
        var filename: String { "ClashDisplay-Bold" }
    }
    
    static func clash(size: CGFloat, weight: ClashWeight = .bold) -> Font {
        return .custom(weight.filename, size: size)
    }
}

extension View {
    func clash(size: CGFloat, weight: Font.ClashWeight = .bold) -> some View {
        self.font(.clash(size: size, weight: weight))
    }
}
