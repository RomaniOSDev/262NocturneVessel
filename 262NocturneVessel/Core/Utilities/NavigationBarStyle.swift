import UIKit

enum NavigationBarStyle {
    static func applyTransparentBackground() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "AppTextPrimary") ?? .white
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "AppTextPrimary") ?? .white
        ]

        let nav = UINavigationBar.appearance()
        nav.standardAppearance = appearance
        nav.scrollEdgeAppearance = appearance
        nav.compactAppearance = appearance
        nav.tintColor = UIColor(named: "AppPrimary") ?? .systemYellow
        nav.isTranslucent = true
    }
}
