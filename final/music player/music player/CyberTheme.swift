import SwiftUI

enum CyberTheme {
    static let neonYellow = Color(red: 1.00, green: 0.90, blue: 0.22)
    static let neonPurple = Color(red: 0.78, green: 0.20, blue: 1.00)

    static let background = LinearGradient(
        gradient: Gradient(colors: [
            .black,
            Color(red: 0.14, green: 0.00, blue: 0.25),
            Color(red: 0.05, green: 0.00, blue: 0.10),
            neonYellow.opacity(0.14)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let neonStrokeV = LinearGradient(
        gradient: Gradient(colors: [neonYellow.opacity(0.95), neonPurple.opacity(0.80)]),
        startPoint: .top,
        endPoint: .bottom
    )

    static let neonStrokeH = LinearGradient(
        gradient: Gradient(colors: [neonYellow.opacity(0.95), neonPurple.opacity(0.80)]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let glassFillPrimary: Double = 0.16
    static let glassFillSecondary: Double = 0.11
}
