import SwiftUI

enum Colors {
    static let sky = Color(red: 0.70, green: 0.84, blue: 0.98)
    static let lavender = Color(red: 0.80, green: 0.76, blue: 0.96)
    static let rose = Color(red: 0.98, green: 0.77, blue: 0.84)
    static let mint = Color(red: 0.73, green: 0.93, blue: 0.84)
    static let peach = Color(red: 1.00, green: 0.82, blue: 0.73)
    static let sun = Color(red: 0.98, green: 0.91, blue: 0.71)
    static let periwinkle = Color(red: 0.70, green: 0.74, blue: 0.96)
    static let pistachio = Color(red: 0.78, green: 0.90, blue: 0.68)
    static let blueMint = Color(red: 0.67, green: 0.90, blue: 0.88)

    static let appGradient = LinearGradient(
        colors: [Color.white, Color(red: 0.96, green: 0.98, blue: 1.0), Color(red: 1.0, green: 0.97, blue: 0.98)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
