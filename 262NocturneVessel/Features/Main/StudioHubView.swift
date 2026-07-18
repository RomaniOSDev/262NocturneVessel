import SwiftUI

struct StudioHubView: View {
    @State private var segment = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                studioTab("Projects", tag: 0, icon: "folder.fill")
                studioTab("Tools", tag: 1, icon: "wrench.and.screwdriver.fill")
                studioTab("Insights", tag: 2, icon: "chart.line.uptrend.xyaxis")
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(DepthStyle.elevatedGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(DepthStyle.topSheen)
                            .allowsHitTesting(false)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 1)
                    )
            )
            .softDepth(elevated: false)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)

            Group {
                switch segment {
                case 0:
                    ProjectsView()
                case 1:
                    StudioToolsView()
                default:
                    FontTrendInsightsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func studioTab(_ title: String, tag: Int, icon: String) -> some View {
        Button {
            FeedbackHelper.lightTap()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                segment = tag
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                Text(title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(segment == tag ? Color("AppBackground") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(
                Group {
                    if segment == tag {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(DepthStyle.primaryButtonGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(DepthStyle.topSheen)
                                    .allowsHitTesting(false)
                            )
                            .shadow(color: DepthStyle.glowShadowColor, radius: 4, y: 2)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

struct StudioToolsView: View {
    private let tools: [(title: String, detail: String, icon: String, badge: String, destination: ToolDestination)] = [
        ("Compare Pairs", "Side-by-side review with shared copy", "rectangle.split.2x1", "Review", .compare),
        ("Mood Match", "Brief tags → suggested pairings", "sparkles", "Brief", .mood),
        ("Role Library", "Display / UI / Editorial / Code scales", "list.bullet.rectangle", "Scale", .roles),
        ("Delivery Checklist", "Handoff checklist per pair", "checklist", "Ship", .checklist)
    ]

    private enum ToolDestination {
        case compare, mood, roles, checklist
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeaderLabel(
                                title: "Designer toolkit",
                                subtitle: "Utilities that go beyond saving font names"
                            )
                            Text("Each tool helps you decide, compare, and hand off typography with confidence.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .surfaceCard()

                        ForEach(Array(tools.enumerated()), id: \.offset) { _, tool in
                            NavigationLink {
                                destinationView(tool.destination)
                                    .hidesTabBar()
                            } label: {
                                ToolCardCell(
                                    title: tool.title,
                                    detail: tool.detail,
                                    icon: tool.icon,
                                    badge: tool.badge
                                )
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded {
                                FeedbackHelper.lightTap()
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .tabBarContentInset(extra: 24)
                }
                .clearScrollBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Studio Tools")
            .navigationBarTitleDisplayMode(.inline)
            .appNavBarChrome()
        }
        .transparentScreenChrome()
    }

    @ViewBuilder
    private func destinationView(_ destination: ToolDestination) -> some View {
        switch destination {
        case .compare:
            SideBySideCompareView()
        case .mood:
            MoodMatchView()
        case .roles:
            RoleLibraryView()
        case .checklist:
            ChecklistHubView()
        }
    }
}
