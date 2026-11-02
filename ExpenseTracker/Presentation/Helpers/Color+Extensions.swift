//
//  Color+Extensions.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Color utilities and hex parser for category badges and charts.
//

import SwiftUI

extension Color {
    /// Initializes a Color from a 6-character hex string (e.g. "#FF5722" or "FF5722").
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, int >> 24)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Semantic palette
    static let expenseRed = Color(hex: "#EF4444")
    static let incomeGreen = Color(hex: "#10B981")
    static let brandPrimary = Color(hex: "#6366F1")
    static let brandSecondary = Color(hex: "#8B5CF6")
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
}
