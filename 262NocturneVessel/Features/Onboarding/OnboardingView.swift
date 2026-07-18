import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var page = 0

    private let pages: [(headline: String, detail: String, image: String, symbol: String)] = [
        (
            "Design Better Fonts",
            "Create harmonious font pairs with ease.",
            "HomeHero",
            "text.book.closed.fill"
        ),
        (
            "Craft Pairings",
            "Select and combine fonts to create unique sets.",
            "HomeCompare",
            "rectangle.split.2x1.fill"
        ),
        (
            "Start Designing",
            "Begin by selecting your first pair of fonts.",
            "HomeCanvas",
            "paintbrush.pointed.fill"
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageContent(
                            headline: pages[index].headline,
                            detail: pages[index].detail,
                            imageName: pages[index].image,
                            symbol: pages[index].symbol,
                            pageIndex: index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: page)

                bottomChrome
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            NavigationBarStyle.applyTransparentBackground()
        }
    }

    private var bottomChrome: some View {
        VStack(spacing: 18) {
            pageIndicator

            Button {
                FeedbackHelper.lightTap()
                if page < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        page += 1
                    }
                } else {
                    store.completeOnboarding()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(page < pages.count - 1 ? "Next" : "Get Started")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Image(systemName: page < pages.count - 1 ? "arrow.right" : "checkmark")
                        .font(.subheadline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .primaryButtonStyle()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .background(
            ZStack {
                DepthStyle.elevatedGradient
                DepthStyle.topSheen
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Color("AppPrimary").opacity(0.35), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 12)
                .allowsHitTesting(false)
            }
            .shadow(color: Color.black.opacity(0.3), radius: 10, y: -4)
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(
                        index == page
                        ? DepthStyle.primaryButtonGradient
                        : LinearGradient(
                            colors: [Color("AppTextSecondary").opacity(0.35), Color("AppTextSecondary").opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: index == page ? 22 : 8, height: 8)
                    .shadow(
                        color: index == page ? DepthStyle.glowShadowColor : .clear,
                        radius: 4,
                        y: 1
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: page)
            }
        }
    }
}

private struct OnboardingPageContent: View {
    let headline: String
    let detail: String
    let imageName: String
    let symbol: String
    let pageIndex: Int
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Spacer(minLength: 12)

                illustrationCard
                    .scaleEffect(appeared ? 1 : 0.82)
                    .opacity(appeared ? 1 : 0)

                textCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .clearScrollBackground()
        .onAppear {
            appeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                appeared = true
            }
        }
        .onChange(of: pageIndex) { _ in
            appeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }

    private var illustrationCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.05),
                            Color("AppBackground").opacity(0.35),
                            Color("AppBackground").opacity(0.88)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(DepthStyle.primaryButtonGradient)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .fill(DepthStyle.topSheen)
                                .allowsHitTesting(false)
                        )
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color("AppBackground"))
                }
                .glowDepth()

                OnboardingMiniPreview(pageIndex: pageIndex)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color("AppPrimary").opacity(0.55),
                            Color("AppAccent").opacity(0.18),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .softDepth(elevated: true)
    }

    private var textCard: some View {
        VStack(spacing: 12) {
            Text(headline)
                .font(.title.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(detail)
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.8)

            HStack(spacing: 6) {
                StatusChip(title: "Step \(pageIndex + 1)", emphasized: true)
                StatusChip(title: "of 3")
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(DepthCardBackground())
        .softDepth(elevated: true)
    }
}

private struct OnboardingMiniPreview: View {
    let pageIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sampleHeadline)
                .font(.system(size: 16, weight: .bold, design: pageIndex == 1 ? .serif : .default))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(sampleBody)
                .font(.system(size: 11, weight: .regular, design: pageIndex == 2 ? .rounded : .serif))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("AppSurface").opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.25), lineWidth: 1)
                )
        )
    }

    private var sampleHeadline: String {
        switch pageIndex {
        case 0: return "Aa · Pair Preview"
        case 1: return "Headline + Body"
        default: return "Start a layout"
        }
    }

    private var sampleBody: String {
        switch pageIndex {
        case 0: return "Balanced contrast in one glance"
        case 1: return "Combine two faces into one set"
        default: return "Open canvas and refine roles"
        }
    }
}
