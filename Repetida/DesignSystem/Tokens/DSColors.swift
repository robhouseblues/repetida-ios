import SwiftUI

enum DSColors {
    // MARK: - Base palette (dark neutral canvas + green primary / gold secondary)

    static let background = Color(red: 10 / 255, green: 10 / 255, blue: 12 / 255)
    static let screenBackground = Color(red: 3 / 255, green: 3 / 255, blue: 4 / 255)
    static let surface = Color(red: 20 / 255, green: 20 / 255, blue: 24 / 255)
    static let primaryText = Color(red: 248 / 255, green: 242 / 255, blue: 224 / 255)
    static let secondaryText = Color(red: 148 / 255, green: 148 / 255, blue: 154 / 255)

    // MARK: - Brand colors

    /// Primary — Brazilian flag green for strokes, icons, and checkmarks (#009739)
    static let primary = Color(red: 0 / 255, green: 151 / 255, blue: 57 / 255)
    /// UI chrome — slightly darker green for borders and outlines (#007A32)
    static let primaryChrome = Color(red: 0 / 255, green: 122 / 255, blue: 50 / 255)
    /// Brighter variant for progress strokes and tab tints only (#1DB954)
    static let primaryBright = Color(red: 29 / 255, green: 185 / 255, blue: 84 / 255)
    /// Deep verde for subtle background washes (#005722)
    static let primaryDeep = Color(red: 0 / 255, green: 87 / 255, blue: 34 / 255)
    /// Desaturated dark green for low-opacity fills (#006B28)
    static let primaryMuted = Color(red: 0 / 255, green: 107 / 255, blue: 40 / 255)

    /// Secondary — foil gold (#EDB836)
    static let secondary = Color(red: 237 / 255, green: 184 / 255, blue: 54 / 255)
    static let secondaryShimmer = Color(red: 255 / 255, green: 220 / 255, blue: 130 / 255)

    static let eliminatedMuted = Color(red: 8 / 255, green: 8 / 255, blue: 9 / 255).opacity(0.85)

    // MARK: - Semantic aliases (legacy names)

    static let accent = secondary
    static let accentSecondary = primary

    static let standingsHeader = primaryDeep

    static let pitchDeep = background
    static let pitchMid = standingsHeader

    static let goldFoil = secondary
    static let goldShimmer = secondaryShimmer

    static let textPrimary = primaryText
    static let textMuted = secondaryText

    static let owned = primary
    static let missing = eliminatedMuted
    static let duplicate = secondary

    static let cardSurface = surface
    static let cardBorder = primaryChrome.opacity(0.28)

    static let stadiumGradient = LinearGradient(
        colors: [
            background,
            surface.opacity(0.55),
            background,
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let progressGradient = LinearGradient(
        colors: [primary, primary.opacity(0.85), secondary.opacity(0.35), primary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
