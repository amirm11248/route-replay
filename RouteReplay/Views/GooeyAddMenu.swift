import SwiftUI

/// An upward fan adapted from the supplied SwiftUI gooey-menu example.
/// The parent owns replay actions and the initial three-second introduction.
struct GooeyAddMenu: View {
    let expanded: Bool
    let isPlaying: Bool
    let speedLabel: String
    var onToggle: () -> Void
    var onPlayback: () -> Void
    var onSpeed: () -> Void
    var onCamera: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ReplayMatteMaterial()
                .mask(GooeyBackground(progress: expanded ? 1 : 0))
                .allowsHitTesting(false)

            if expanded {
                actionButton(
                    identifier: isPlaying ? "replay-pause-button" : "replay-resume-button",
                    label: isPlaying ? "Pause replay" : "Resume replay",
                    offset: GooeyFanGeometry.playback, action: onPlayback
                ) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                }
    
                actionButton(identifier: "replay-speed-button", label: "Replay speed, \(speedLabel)", offset: GooeyFanGeometry.speed, action: onSpeed) {
                    Text(speedLabel).font(.subheadline.weight(.semibold)).monospacedDigit()
                }
    
                actionButton(identifier: "replay-settings-button", label: "Camera controls", offset: GooeyFanGeometry.camera, action: onCamera) {
                    Image(systemName: "slider.horizontal.3")
                }
            }

            Button(action: onToggle) {
                Image(systemName: "plus")
                    .rotationEffect(.degrees(expanded ? 45 : 0))
                    .modifier(MenuCircle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("replay-controls-toggle")
            .accessibilityLabel(expanded ? "Hide replay controls" : "Show replay controls")
            .accessibilityValue(expanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Pause, change speed, or adjust the camera")
        }
        .frame(width: GooeyFanGeometry.width, height: GooeyFanGeometry.height)
        .frame(height: expanded ? GooeyFanGeometry.height : GooeyFanGeometry.buttonSize, alignment: .bottom)
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.78), value: expanded)
        .transaction { if reduceMotion { $0.animation = nil } }
    }

    private func actionButton<Content: View>(
        identifier: String, label: String, offset: CGPoint,
        action: @escaping () -> Void, @ViewBuilder content: () -> Content
    ) -> some View {
        Button(action: action) {
            content().modifier(MenuCircle())
        }
        .buttonStyle(.plain)
        .offset(x: offset.x, y: offset.y)
        .transition(reduceMotion ? .opacity : .offset(x: -offset.x, y: -offset.y).combined(with: .scale(scale: 0.7)).combined(with: .opacity))
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(label)
    }

    private struct MenuCircle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 21, weight: .medium))
                .foregroundStyle(AppTheme.primary)
                .frame(width: GooeyFanGeometry.buttonSize, height: GooeyFanGeometry.buttonSize)
                .overlay(Circle().strokeBorder(AppTheme.primary.opacity(0.12), lineWidth: 0.5))
                .contentShape(Circle())
        }
    }
}

/// Equal angular spacing and radius keep the fan balanced and its circles apart.
private enum GooeyFanGeometry {
    static let buttonSize: CGFloat = 52
    static let width: CGFloat = 208
    static let height: CGFloat = 216
    static let playback = position(angle: 150)
    static let speed = position(angle: 120)
    static let camera = position(angle: 90)

    private static func position(angle: Double) -> CGPoint {
        let radians = angle * .pi / 180
        return CGPoint(x: CGFloat(144 * cos(radians)), y: CGFloat(-144 * sin(radians)))
    }
}

/// The mask merges the circles while they travel; labels remain crisp above it.
private struct GooeyBackground: View, Animatable {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Canvas { context, size in
            // Blur only while moving. At rest the mask is made of separate,
            // crisp circles, so no liquid bridge remains between the buttons.
            let phase = min(max(Double(progress), 0), 1)
            let blurRadius = 9 * sin(.pi * phase)
            if blurRadius > 0.01 {
                context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                context.addFilter(.blur(radius: CGFloat(blurRadius)))
            }
            context.drawLayer { layer in
                let radius = GooeyFanGeometry.buttonSize / 2
                let center = CGPoint(x: size.width - radius, y: size.height - radius)
                let offsets: [CGPoint] = [
                    .zero,
                    GooeyFanGeometry.playback,
                    GooeyFanGeometry.speed,
                    GooeyFanGeometry.camera
                ]
                for offset in offsets {
                    let rect = CGRect(x: center.x + offset.x * progress - radius, y: center.y + offset.y * progress - radius, width: GooeyFanGeometry.buttonSize, height: GooeyFanGeometry.buttonSize)
                    layer.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
        }
    }
}

/// Soft blur rather than reflective glass; map imagery remains visible beneath.
struct ReplayMatteMaterial: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        if reduceTransparency {
            AppTheme.surface
        } else {
            Rectangle()
                .fill(.thinMaterial)
                .overlay(AppTheme.surface.opacity(contrast == .increased ? 0.45 : 0.12))
        }
    }
}

struct ReplayChromeHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
