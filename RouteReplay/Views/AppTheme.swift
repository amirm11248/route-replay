import SwiftUI
import UIKit

/// Platinum in light mode, Onyx in dark mode. Apple Maps owns its rendering.
enum AppTheme {
    static let background = color(light: 0xF5F5F5, dark: 0x191919)
    static let surface = color(light: 0xFBFBFB, dark: 0x252525)
    static let primary = color(light: 0x242424, dark: 0xF0F0F0)
    static let secondary = color(light: 0x666666, dark: 0xBCBCBC)
    static let line = color(light: 0xD9D9D9, dark: 0x3E3E3E)
    static let accent = color(light: 0x484848, dark: 0xBEC8D2)
    static let actionBackground = color(light: 0x262626, dark: 0xEDEDED)
    static let actionForeground = color(light: 0xF7F7F7, dark: 0x242424)
    static let shadow = color(light: 0x282828, dark: 0x111111)

    private static func color(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let value = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((value >> 16) & 0xFF) / 255,
                           green: CGFloat((value >> 8) & 0xFF) / 255,
                           blue: CGFloat(value & 0xFF) / 255, alpha: 1)
        })
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct ReplayActionButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.actionForeground)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(AppTheme.actionBackground, in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: AppTheme.shadow.opacity(0.10), radius: 8, y: 4)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
