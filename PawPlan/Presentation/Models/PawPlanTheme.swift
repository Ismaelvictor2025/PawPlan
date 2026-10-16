//
//  PawPlanTheme.swift
//  PawPlan
//
//  Created for PawPlan Electric Ocean Design System.
//

import SwiftUI
import UIKit

public enum PawPlanTheme {
    // Helper to generate dynamic adaptive colors
    private static func dynamicColor(lightHex: String, darkHex: String, lightOpacity: Double = 1.0, darkOpacity: Double = 1.0) -> Color {
        Color(uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor(Color(hex: darkHex).opacity(darkOpacity))
            } else {
                return UIColor(Color(hex: lightHex).opacity(lightOpacity))
            }
        })
    }

    // MARK: - Core Palette (Light & Dark Mode Aware)
    public static let background = dynamicColor(lightHex: "#F8FAFC", darkHex: "#080F20")
    public static let cardBackground = dynamicColor(lightHex: "#FFFFFF", darkHex: "#0E1B33")
    public static let cardSurface = dynamicColor(lightHex: "#FFFFFF", darkHex: "#0E1B33")
    public static let cardBackgroundElevated = dynamicColor(lightHex: "#F1F5F9", darkHex: "#142546")
    public static let cardBorder = dynamicColor(lightHex: "#CBD5E1", darkHex: "#1E3563", lightOpacity: 0.8, darkOpacity: 0.6)
    public static let midnightNavy = Color(hex: "#080F20")

    // MARK: - Electric Ocean Brand Accents
    public static let electricBlue = Color(hex: "#125BCE")
    public static let electricTurquoise = Color(hex: "#15D9D2")
    public static let lightCyan = dynamicColor(lightHex: "#0284C7", darkHex: "#85F4FF")

    // MARK: - Feature Accents
    public static let walks = Color(hex: "#125BCE")       // Electric Blue
    public static let walk = walks
    public static let feeding = dynamicColor(lightHex: "#0D9488", darkHex: "#15D9D2")     // Turquoise
    public static let grooming = Color(hex: "#9D4EDD")    // Violet
    public static let vetHealth = Color(hex: "#FF2A85")   // Pink
    public static let training = Color(hex: "#FF7B00")    // Orange
    public static let medication = dynamicColor(lightHex: "#16A34A", darkHex: "#00E676")  // Green
    public static let positiveGreen = dynamicColor(lightHex: "#16A34A", darkHex: "#00E676")
    public static let expenses = Color(hex: "#FFB703")    // Amber
    public static let amber = Color(hex: "#FFB703")
    public static let petPlaces = dynamicColor(lightHex: "#0284C7", darkHex: "#00E5FF")   // Vivid Cyan

    // MARK: - Text & Secondary
    public static let textPrimary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : UIColor(Color(hex: "#0F172A"))
    })
    public static let textSecondary = dynamicColor(lightHex: "#475569", darkHex: "#94A3B8")
    public static let textTertiary = dynamicColor(lightHex: "#94A3B8", darkHex: "#64748B")
    public static let subtext = dynamicColor(lightHex: "#475569", darkHex: "#94A3B8")

    // MARK: - Gradients
    public static let heroGradient = LinearGradient(
        colors: [Color(hex: "#15D9D2"), Color(hex: "#0EB8B2"), Color(hex: "#0CA1A8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let cardGradient = LinearGradient(
        colors: [cardSurface, cardBackgroundElevated],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let electricBlueGradient = LinearGradient(
        colors: [Color(hex: "#1E6FE8"), Color(hex: "#125BCE")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let turquoiseGradient = LinearGradient(
        colors: [Color(hex: "#26E5DE"), Color(hex: "#15D9D2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let violetGradient = LinearGradient(
        colors: [Color(hex: "#B366FF"), Color(hex: "#9D4EDD")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let pinkGradient = LinearGradient(
        colors: [Color(hex: "#FF4D9E"), Color(hex: "#FF2A85")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let orangeGradient = LinearGradient(
        colors: [Color(hex: "#FF9426"), Color(hex: "#FF7B00")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let greenGradient = LinearGradient(
        colors: [Color(hex: "#26FF94"), Color(hex: "#00E676")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let amberGradient = LinearGradient(
        colors: [Color(hex: "#FFC73B"), Color(hex: "#FFB703")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let cyanGradient = LinearGradient(
        colors: [Color(hex: "#85F4FF"), Color(hex: "#00E5FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
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
