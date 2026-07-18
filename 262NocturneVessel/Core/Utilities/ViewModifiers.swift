import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

struct ShakeModifier: ViewModifier {
    var shakes: CGFloat

    func body(content: Content) -> some View {
        content.modifier(ShakeEffect(animatableData: shakes))
    }
}

extension View {
    func shake(trigger: CGFloat) -> some View {
        modifier(ShakeModifier(shakes: trigger))
    }

    func bottomButtonStyle() -> some View {
        frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: DepthStyle.controlRadius, style: .continuous)
                    .fill(DepthStyle.primaryButtonGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: DepthStyle.controlRadius, style: .continuous)
                            .fill(DepthStyle.topSheen)
                            .allowsHitTesting(false)
                    )
            )
            .foregroundStyle(Color("AppBackground"))
            .font(.headline.weight(.semibold))
            .glowDepth()
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    func primaryButtonStyle() -> some View {
        padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DepthStyle.primaryButtonGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(DepthStyle.topSheen)
                            .allowsHitTesting(false)
                    )
            )
            .foregroundStyle(Color("AppBackground"))
            .font(.headline.weight(.semibold))
            .glowDepth()
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
