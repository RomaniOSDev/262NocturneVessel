import SwiftUI
import UIKit
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    private var versionString: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 18) {
                        StatsOverviewCell(
                            pairs: store.itemsCreated,
                            minutes: store.totalMinutesUsed,
                            streak: store.streakDays,
                            sessions: store.totalSessionsCompleted
                        )

                        VStack(spacing: 0) {
                            Button {
                                FeedbackHelper.lightTap()
                                rateApp()
                            } label: {
                                SettingsRowCell(title: "Rate Us", systemImage: "star.fill")
                            }
                            .buttonStyle(.plain)

                            Divider().overlay(Color("AppTextSecondary").opacity(0.25))

                            Button {
                                FeedbackHelper.lightTap()
                                openLink(.privacyPolicy)
                            } label: {
                                SettingsRowCell(title: "Privacy", systemImage: "hand.raised.fill")
                            }
                            .buttonStyle(.plain)

                            Divider().overlay(Color("AppTextSecondary").opacity(0.25))

                            Button {
                                FeedbackHelper.lightTap()
                                openLink(.termsOfUse)
                            } label: {
                                SettingsRowCell(title: "Terms", systemImage: "doc.plaintext.fill")
                            }
                            .buttonStyle(.plain)

                            Divider().overlay(Color("AppTextSecondary").opacity(0.25))

                            Button {
                                FeedbackHelper.lightTap()
                                showResetAlert = true
                            } label: {
                                SettingsRowCell(title: "Reset All Data", systemImage: "trash.fill", isDestructive: true)
                            }
                            .buttonStyle(.plain)
                        }
                        .background(DepthCardBackground())
                        .softDepth(elevated: true)

                        Text("Version \(versionString)")
                            .font(.footnote)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .tabBarContentInset(extra: 24)
                }
                .clearScrollBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .appNavBarChrome()
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    FeedbackHelper.lightTap()
                }
                Button("Reset", role: .destructive) {
                    FeedbackHelper.warning()
                    store.resetAllData()
                }
            } message: {
                Text("This permanently clears pairs, insights, achievements, and settings on this device.")
            }
        }
        .transparentScreenChrome()
    }

    private func openLink(_ link: AppLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
