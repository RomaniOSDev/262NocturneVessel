import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(title: String, icon: String)]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tabs.indices, id: \.self) { index in
                tabButton(index: index)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            ZStack {
                DepthStyle.elevatedGradient
                DepthStyle.topSheen
                LinearGradient(
                    colors: [Color("AppPrimary").opacity(0.12), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .shadow(color: Color.black.opacity(0.32), radius: 10, y: -3)
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(index: Int) -> some View {
        let isSelected = selectedTab == index
        return Button {
            FeedbackHelper.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tabs[index].icon)
                    .font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 26)
                Text(tabs[index].title)
                    .font(.caption2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(DepthStyle.primaryButtonGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(DepthStyle.topSheen)
                                    .allowsHitTesting(false)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color("AppAccent").opacity(0.55), lineWidth: 1)
                            )
                            .shadow(color: DepthStyle.glowShadowColor, radius: 5, y: 2)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(TabPressStyle())
    }
}

private struct TabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
