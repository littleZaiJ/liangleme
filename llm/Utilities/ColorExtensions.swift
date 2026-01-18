import SwiftUI

extension Color {
    init(hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let kleinBlue = Color(hex: "#002FA7")
    static let deadGrey = Color(hex: "#333333")
    static let hopePink = Color(hex: "#FFC0CB")

    static func interpolate(from color1: Color, to color2: Color, fraction: Double) -> Color {
        let fraction = max(0, min(1, fraction))

        let c1Components = UIColor(color1).cgColor.components ?? [0, 0, 0, 1]
        let c2Components = UIColor(color2).cgColor.components ?? [0, 0, 0, 1]

        let r = c1Components[0] + (c2Components[0] - c1Components[0]) * fraction
        let g = c1Components[1] + (c2Components[1] - c1Components[1]) * fraction
        let b = c1Components[2] + (c2Components[2] - c1Components[2]) * fraction

        return Color(red: r, green: g, blue: b)
    }

    static func backgroundForElapsedTime(_ seconds: TimeInterval) -> Color {
        let minutes = seconds / 60

        if minutes < 10 {
            let fraction = minutes / 10
            return interpolate(from: .black, to: .hopePink, fraction: fraction)
        } else if minutes < 120 {
            let fraction = (minutes - 10) / 110
            return interpolate(from: .hopePink, to: .kleinBlue, fraction: fraction)
        } else if minutes < 1440 {
            let fraction = (minutes - 120) / 1320
            return interpolate(from: .kleinBlue, to: .deadGrey, fraction: fraction)
        } else {
            return .black
        }
    }
}
