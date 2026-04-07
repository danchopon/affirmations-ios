import SwiftUI
import UIKit

// MARK: - Colors (programmatic -- no asset catalog needed)

public extension Color {
    static let appPrimary = Color(red: 0.44, green: 0.36, blue: 0.82)     // indigo-ish
    static let appSecondary = Color(red: 0.96, green: 0.76, blue: 0.34)   // warm amber
    static let appBackground = Color(UIColor.systemBackground)
    static let moodLow = Color(red: 0.90, green: 0.40, blue: 0.35)
    static let moodMid = Color(red: 0.97, green: 0.76, blue: 0.35)
    static let moodHigh = Color(red: 0.36, green: 0.78, blue: 0.55)
}

// MARK: - Typography

public extension Font {
    static let appTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let appHeadline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let appBody = Font.system(size: 16, weight: .regular, design: .default)
    static let appCaption = Font.system(size: 13, weight: .regular, design: .default)
}

// MARK: - Mood color helper

public extension Int {
    /// Returns a color on a gradient from moodLow (1) to moodHigh (10).
    var moodColor: Color {
        let t = Double(Swift.max(1, Swift.min(10, self)) - 1) / 9.0
        if t < 0.5 {
            return Color.interpolate(from: .moodLow, to: .moodMid, t: t * 2)
        } else {
            return Color.interpolate(from: .moodMid, to: .moodHigh, t: (t - 0.5) * 2)
        }
    }
}

private extension Color {
    static func interpolate(from: Color, to: Color, t: Double) -> Color {
        let clamp = { (v: Double) in Swift.max(0, Swift.min(1, v)) }
        let f = UIColor(from)
        let g = UIColor(to)
        var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var gr: CGFloat = 0, gg: CGFloat = 0, gb: CGFloat = 0, ga: CGFloat = 0
        f.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        g.getRed(&gr, green: &gg, blue: &gb, alpha: &ga)
        return Color(
            red: clamp(Double(fr) + (Double(gr) - Double(fr)) * t),
            green: clamp(Double(fg) + (Double(gg) - Double(fg)) * t),
            blue: clamp(Double(fb) + (Double(gb) - Double(fb)) * t)
        )
    }
}
