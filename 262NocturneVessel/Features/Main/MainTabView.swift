import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @State private var tabBarHiddenCount = 0

    private let tabs = [
        (title: "Home", icon: "house.fill"),
        (title: "Studio", icon: "square.grid.2x2.fill"),
        (title: "Badges", icon: "rosette"),
        (title: "Settings", icon: "gearshape.fill")
    ]

    private var isTabBarVisible: Bool {
        tabBarHiddenCount <= 0
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackgroundView()

            Group {
                switch selectedTab {
                case 0:
                    FontPairDesignerView()
                case 1:
                    StudioHubView()
                case 2:
                    AchievementsView()
                default:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.tabBarClearance, isTabBarVisible ? TabBarLayout.clearance : 0)
            .environment(\.tabBarVisibilityRegistrar, registerTabBarHidden)

            if isTabBarVisible {
                CustomTabBar(selectedTab: $selectedTab, tabs: tabs)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if let achievement = store.pendingAchievementBanner {
                VStack {
                    AchievementBannerView(achievement: achievement)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .padding(.top, 8)
                .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isTabBarVisible)
        .preferredColorScheme(.dark)
        .onAppear {
            NavigationBarStyle.applyTransparentBackground()
            store.recordSessionIfNeeded()
            store.startUsageTracking()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                store.recordSessionIfNeeded()
                store.startUsageTracking()
            } else {
                store.pauseUsageTracking()
            }
        }
    }

    private func registerTabBarHidden(_ hidden: Bool) {
        tabBarHiddenCount = max(0, tabBarHiddenCount + (hidden ? 1 : -1))
    }
}
