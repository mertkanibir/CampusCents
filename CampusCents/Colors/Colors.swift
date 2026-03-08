import SwiftUI

enum Colors {
    static let sky = Color(red: 0.23, green: 0.55, blue: 0.97)
    static let lavender = Color(red: 0.53, green: 0.41, blue: 0.95)
    static let rose = Color(red: 0.94, green: 0.34, blue: 0.53)
    static let mint = Color(red: 0.13, green: 0.73, blue: 0.52)
    static let peach = Color(red: 0.98, green: 0.54, blue: 0.35)
    static let sun = Color(red: 0.95, green: 0.69, blue: 0.17)
    static let periwinkle = Color(red: 0.33, green: 0.43, blue: 0.96)
    static let pistachio = Color(red: 0.45, green: 0.76, blue: 0.23)
    static let blueMint = Color(red: 0.12, green: 0.74, blue: 0.79)

    static func scrollEdgeOverlayTop(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.08, green: 0.10, blue: 0.18)
            : Color(red: 0.93, green: 0.97, blue: 1.00)
    }

    static func appGradient(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark
                ? [
                    Color(red: 0.08, green: 0.10, blue: 0.18),
                    Color(red: 0.11, green: 0.14, blue: 0.24),
                    Color(red: 0.16, green: 0.11, blue: 0.21)
                ]
                : [
                    Color(red: 0.93, green: 0.97, blue: 1.00),
                    Color(red: 0.94, green: 0.95, blue: 1.00),
                    Color(red: 1.00, green: 0.93, blue: 0.96)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardFill(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark
                ? [
                    Color.white.opacity(0.10),
                    Color.white.opacity(0.05)
                ]
                : [
                    Color.white.opacity(0.94),
                    Color(red: 0.98, green: 0.99, blue: 1.00)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.12) : Color(red: 0.74, green: 0.82, blue: 0.97).opacity(0.8)
    }

    static func metricFill(_ tint: Color, scheme: ColorScheme) -> Color {
        scheme == .dark ? tint.opacity(0.26) : tint.opacity(0.18)
    }

    static func metricStroke(_ tint: Color, scheme: ColorScheme) -> Color {
        scheme == .dark ? tint.opacity(0.5) : tint.opacity(0.65)
    }
}
