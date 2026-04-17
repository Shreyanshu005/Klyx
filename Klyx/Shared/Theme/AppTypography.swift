//
//  AppTypography.swift
//  Klyx
//
//  Created by Shreyanshu on 17/04/26.
//

import SwiftUI

/// Centralized typography definitions.
/// Uses SF Pro (system) with rounded design for numbers and key headings.
enum AppTypography {
    // MARK: - Headings
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title, design: .rounded, weight: .bold)
    static let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
    static let title3 = Font.system(.title3, design: .rounded, weight: .semibold)

    // MARK: - Body
    static let headline = Font.system(.headline, design: .default, weight: .semibold)
    static let body = Font.system(.body, design: .default)
    static let callout = Font.system(.callout, design: .default)
    static let subheadline = Font.system(.subheadline, design: .default)

    // MARK: - Captions
    static let caption = Font.system(.caption, design: .default)
    static let caption2 = Font.system(.caption2, design: .default)

    // MARK: - Numbers (monospaced for alignment)
    static let scoreDisplay = Font.system(size: 48, weight: .bold, design: .rounded)
    static let statValue = Font.system(size: 24, weight: .bold, design: .rounded)
    static let ratingValue = Font.system(size: 36, weight: .bold, design: .rounded)
    static let monoCaption = Font.system(.caption, design: .monospaced)
}
