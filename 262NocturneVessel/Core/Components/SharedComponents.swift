import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            DepthStyle.screenBackground

            // Cheap volume blobs — no Canvas loops, no blur, no animation.
            Ellipse()
                .fill(Color("AppPrimary").opacity(0.10))
                .frame(width: 280, height: 280)
                .offset(x: 120, y: -160)
                .allowsHitTesting(false)

            Ellipse()
                .fill(Color("AppAccent").opacity(0.07))
                .frame(width: 220, height: 220)
                .offset(x: -130, y: 240)
                .allowsHitTesting(false)

            Ellipse()
                .fill(Color("AppSurface").opacity(0.35))
                .frame(width: 180, height: 180)
                .offset(x: 40, y: 420)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

struct EmptyStateView: View {
    let symbolName: String
    let message: String
    var title: String? = nil

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(DepthStyle.elevatedGradient)
                    .frame(width: 110, height: 110)
                    .softDepth(elevated: false)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.55), Color("AppAccent").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                    )
                    .frame(width: 126, height: 126)
                Image(systemName: symbolName)
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(Color("AppPrimary"))
            }

            if let title {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .surfaceCard()
    }
}

struct SuccessCheckBadge: View {
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 56))
            .foregroundStyle(Color("AppPrimary"))
            .glowDepth()
    }
}

struct AchievementBannerView: View {
    let achievement: AchievementDefinition

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: achievement.symbolName, size: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppBackground").opacity(0.8))
                Text(achievement.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppBackground"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DepthStyle.primaryButtonGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(DepthStyle.topSheen)
                        .allowsHitTesting(false)
                )
        )
        .glowDepth()
        .padding(.horizontal, 16)
    }
}

struct FontPreviewText: View {
    let fontName: String
    let text: String
    let role: FontRole
    var size: CGFloat = 22

    var body: some View {
        Text(text)
            .font(
                .system(
                    size: size,
                    weight: AvailableFonts.weight(for: role),
                    design: AvailableFonts.design(for: fontName)
                )
            )
            .foregroundStyle(Color("AppTextPrimary"))
            .lineLimit(2)
            .minimumScaleFactor(0.7)
    }
}
