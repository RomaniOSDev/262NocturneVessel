import SwiftUI

enum TabBarLayout {
    /// Space reserved for the custom tab bar on tab-root scroll content.
    static let clearance: CGFloat = 96
}

private struct TabBarClearanceKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

private struct TabBarVisibilityRegistrarKey: EnvironmentKey {
    static let defaultValue: ((Bool) -> Void)? = nil
}

extension EnvironmentValues {
    var tabBarClearance: CGFloat {
        get { self[TabBarClearanceKey.self] }
        set { self[TabBarClearanceKey.self] = newValue }
    }

    var tabBarVisibilityRegistrar: ((Bool) -> Void)? {
        get { self[TabBarVisibilityRegistrarKey.self] }
        set { self[TabBarVisibilityRegistrarKey.self] = newValue }
    }
}

private struct HidesTabBarModifier: ViewModifier {
    @Environment(\.tabBarVisibilityRegistrar) private var registrar

    func body(content: Content) -> some View {
        content
            .onAppear { registrar?(true) }
            .onDisappear { registrar?(false) }
    }
}

private struct TabBarContentInsetModifier: ViewModifier {
    @Environment(\.tabBarClearance) private var clearance
    var extra: CGFloat

    func body(content: Content) -> some View {
        content.padding(.bottom, max(0, clearance) + extra)
    }
}

extension View {
    func clearScrollBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
    }

    func transparentScreenChrome() -> some View {
        background(Color.clear)
    }

    /// Hide the custom tab bar while this screen is visible (reference-counted).
    func hidesTabBar() -> some View {
        modifier(HidesTabBarModifier())
    }

    /// Bottom inset for tab-root scroll content so it clears the custom tab bar.
    func tabBarContentInset(extra: CGFloat = 20) -> some View {
        modifier(TabBarContentInsetModifier(extra: extra))
    }

    /// Transparent navigation bar so `AppBackgroundView` shows under the top bar.
    func appNavBarChrome() -> some View {
        toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
