import SwiftUI

/// Lightweight depth tokens — small shadow radii, no blur materials, no nested shadows.
enum DepthStyle {
    static let cardRadius: CGFloat = 18
    static let controlRadius: CGFloat = 14

    static let cardShadowColor = Color.black.opacity(0.28)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 5

    static let softShadowColor = Color.black.opacity(0.18)
    static let softShadowRadius: CGFloat = 4
    static let softShadowY: CGFloat = 2

    static let glowShadowColor = Color("AppPrimary").opacity(0.35)
    static let glowShadowRadius: CGFloat = 6
    static let glowShadowY: CGFloat = 3

    static var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(1.0),
                Color("AppBackground").opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var elevatedGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.92),
                Color("AppBackground").opacity(0.65)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent"), Color("AppPrimary")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentWash: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary").opacity(0.18), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var topSheen: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.14), Color.white.opacity(0.02), Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground"),
                Color("AppSurface").opacity(0.95),
                Color("AppBackground")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct SoftDepthModifier: ViewModifier {
    var elevated: Bool = true

    func body(content: Content) -> some View {
        content
            .compositingGroup()
            .shadow(
                color: elevated ? DepthStyle.cardShadowColor : DepthStyle.softShadowColor,
                radius: elevated ? DepthStyle.cardShadowRadius : DepthStyle.softShadowRadius,
                x: 0,
                y: elevated ? DepthStyle.cardShadowY : DepthStyle.softShadowY
            )
    }
}

struct GlowDepthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .compositingGroup()
            .shadow(
                color: DepthStyle.glowShadowColor,
                radius: DepthStyle.glowShadowRadius,
                x: 0,
                y: DepthStyle.glowShadowY
            )
    }
}

extension View {
    /// One compositing-group + one shadow — safe for scrolling lists.
    func softDepth(elevated: Bool = true) -> some View {
        modifier(SoftDepthModifier(elevated: elevated))
    }

    func glowDepth() -> some View {
        modifier(GlowDepthModifier())
    }
}

struct DepthCardBackground: View {
    var highlighted: Bool = false
    var cornerRadius: CGFloat = DepthStyle.cardRadius

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DepthStyle.elevatedGradient)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(highlighted ? Color("AppAccent").opacity(0.18) : Color("AppPrimary").opacity(0.10))
                    .allowsHitTesting(false)
            )
            .overlay(
                Group {
                    if !highlighted {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(DepthStyle.accentWash)
                            .allowsHitTesting(false)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DepthStyle.topSheen)
                    .allowsHitTesting(false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color("AppPrimary").opacity(highlighted ? 0.65 : 0.35),
                                Color("AppAccent").opacity(0.12),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
