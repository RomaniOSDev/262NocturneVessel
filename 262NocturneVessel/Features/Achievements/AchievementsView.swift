import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 18) {
                        summaryCard

                        SectionHeaderLabel(
                            title: "Badge shelf",
                            subtitle: "Unlocked by real design activity"
                        )

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(AppDataStore.achievementDefinitions) { achievement in
                                AchievementBadgeCard(
                                    achievement: achievement,
                                    unlockedAt: store.achievementsUnlocked[achievement.id]
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .tabBarContentInset(extra: 24)
                }
                .clearScrollBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .appNavBarChrome()
        }
        .transparentScreenChrome()
    }

    private var summaryCard: some View {
        let unlocked = store.achievementsUnlocked.count
        return VStack(alignment: .leading, spacing: 14) {
            SectionHeaderLabel(title: "Progress Snapshot", subtitle: "Pairs, sessions, and streak feed badges")

            HStack(spacing: 10) {
                MetricChip(title: "Pairs", value: "\(store.itemsCreated)", icon: "textformat")
                MetricChip(title: "Sessions", value: "\(store.totalSessionsCompleted)", icon: "bolt.fill")
                MetricChip(title: "Streak", value: "\(store.streakDays)d", icon: "flame.fill")
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(unlocked) of 8 badges unlocked")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Text("\(Int((Double(unlocked) / 8.0) * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color("AppBackground").opacity(0.45))
                        Capsule()
                            .fill(Color("AppAccent"))
                            .frame(width: geo.size.width * CGFloat(unlocked) / 8.0)
                    }
                }
                .frame(height: 8)
            }
        }
        .surfaceCard()
    }
}

private struct AchievementBadgeCard: View {
    let achievement: AchievementDefinition
    let unlockedAt: Date?

    private var isUnlocked: Bool { unlockedAt != nil }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("AppPrimary") : Color("AppBackground").opacity(0.55))
                    .frame(width: 60, height: 60)
                Circle()
                    .stroke(isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.25), lineWidth: 2)
                    .frame(width: 68, height: 68)
                Image(systemName: achievement.symbolName)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color("AppBackground") : Color("AppTextSecondary"))
            }

            Text(achievement.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(achievement.detail)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            StatusChip(title: isUnlocked ? "Unlocked" : "Locked", emphasized: isUnlocked)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 210)
        .background(DepthCardBackground(highlighted: isUnlocked))
        .softDepth(elevated: isUnlocked)
        .opacity(isUnlocked ? 1 : 0.72)
    }
}
