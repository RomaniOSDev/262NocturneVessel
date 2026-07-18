import SwiftUI

struct HomeFeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let imageName: String
    let destination: HomeFeatureDestination
}

enum HomeFeatureDestination: Hashable {
    case mood
    case compare
    case roles
    case projects
}

struct HomeHeroBanner: View {
    let onCreate: () -> Void
    let onExplore: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.05),
                            Color("AppBackground").opacity(0.45),
                            Color("AppBackground").opacity(0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Ellipse()
                        .fill(Color("AppPrimary").opacity(0.18))
                        .frame(width: 140, height: 90)
                        .offset(x: 20, y: -10)
                        .allowsHitTesting(false)
                }

            VStack(alignment: .leading, spacing: 10) {
                Text("Craft pairs that feel intentional")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .shadow(color: Color.black.opacity(0.35), radius: 2, y: 1)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text("Preview layouts, score readability, and export ready-to-use scales.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(3)

                HStack(spacing: 10) {
                    Button(action: onCreate) {
                        Text("New Pair")
                            .font(.subheadline.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
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
                            .glowDepth()
                    }

                    Button(action: onExplore) {
                        Text("Mood Match")
                            .font(.subheadline.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(DepthStyle.surfaceGradient)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color("AppPrimary").opacity(0.55), lineWidth: 1.5)
                                    )
                            )
                            .foregroundStyle(Color("AppPrimary"))
                            .softDepth(elevated: false)
                    }
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.5), Color("AppAccent").opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .softDepth(elevated: true)
    }
}

struct HomeImageFeatureCard: View {
    let title: String
    let detail: String
    let imageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [Color.clear, Color("AppSurface").opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 36)
                    .allowsHitTesting(false)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DepthStyle.elevatedGradient)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 1)
        )
        .softDepth(elevated: true)
    }
}

struct HomeWideImageCard: View {
    let title: String
    let detail: String
    let imageName: String
    let badge: String

    var body: some View {
        HStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 108, height: 108)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                StatusChip(title: badge, emphasized: true)
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                        .font(.title3)
                        .shadow(color: DepthStyle.glowShadowColor, radius: 3, y: 1)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .background(DepthStyle.elevatedGradient)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.4), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .softDepth(elevated: true)
    }
}
