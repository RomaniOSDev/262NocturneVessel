import SwiftUI

// MARK: - Surface helpers

struct SurfaceCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var highlighted: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DepthCardBackground(highlighted: highlighted))
            .softDepth(elevated: true)
    }
}

extension View {
    func surfaceCard(padding: CGFloat = 16, highlighted: Bool = false) -> some View {
        modifier(SurfaceCardModifier(padding: padding, highlighted: highlighted))
    }

    func secondaryButtonStyle() -> some View {
        padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DepthStyle.controlRadius, style: .continuous)
                    .fill(DepthStyle.surfaceGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: DepthStyle.controlRadius, style: .continuous)
                            .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1.5)
                    )
            )
            .foregroundStyle(Color("AppPrimary"))
            .font(.headline.weight(.semibold))
            .softDepth(elevated: false)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

// MARK: - Chips & headers

struct StatusChip: View {
    let title: String
    var emphasized: Bool = false

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundStyle(emphasized ? Color("AppBackground") : Color("AppTextPrimary"))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(
                        emphasized
                        ? DepthStyle.primaryButtonGradient
                        : LinearGradient(
                            colors: [Color("AppBackground").opacity(0.7), Color("AppBackground").opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color("AppPrimary").opacity(emphasized ? 0.0 : 0.2), lineWidth: 1)
            )
            .shadow(
                color: emphasized ? DepthStyle.glowShadowColor.opacity(0.5) : .clear,
                radius: 3,
                y: 1
            )
    }
}

struct MetricChip: View {
    let title: String
    let value: String
    var icon: String? = nil

    var body: some View {
        VStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            }
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.55),
                            Color("AppBackground").opacity(0.28)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.18), lineWidth: 1)
                )
        )
    }
}

struct SectionHeaderLabel: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct IconBadge: View {
    let systemName: String
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DepthStyle.primaryButtonGradient)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(DepthStyle.topSheen)
                        .allowsHitTesting(false)
                )
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(Color("AppBackground"))
        }
        .glowDepth()
    }
}

// MARK: - Pair card cell

struct PairCardCell: View {
    let pair: FontPair
    let isFavorite: Bool
    var isHighlighted: Bool = false
    var score: Int? = nil
    var onFavorite: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                PairGlyphView(font1: pair.font1, font2: pair.font2)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(pair.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer(minLength: 0)
                        if let score {
                            ScoreRing(score: score, size: 36)
                        }
                    }

                    Text(pair.pairDescription.isEmpty ? "Open workspace to refine layout" : pair.pairDescription)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        StatusChip(title: pair.scaleKind.title, emphasized: true)
                        StatusChip(title: pair.category.capitalized)
                    }
                }

                if let onFavorite {
                    Button {
                        FeedbackHelper.lightTap()
                        onFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isFavorite ? Color("AppPrimary") : Color("AppTextSecondary"))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("Aa")
                    .font(.system(size: 28, weight: .bold, design: AvailableFonts.design(for: pair.font1)))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("The quick brown fox")
                    .font(.system(size: 14, weight: .regular, design: AvailableFonts.design(for: pair.font2)))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            }

            HStack {
                Text(pair.font1)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Image(systemName: "plus")
                    .font(.caption2)
                    .foregroundStyle(Color("AppAccent"))
                Text(pair.font2)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .surfaceCard(highlighted: isHighlighted)
    }
}

struct PairGlyphView: View {
    let font1: String
    let font2: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.75),
                            Color("AppBackground").opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 58)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.28), lineWidth: 1)
                )
            VStack(spacing: 0) {
                Text("A")
                    .font(.system(size: 22, weight: .bold, design: AvailableFonts.design(for: font1)))
                Text("a")
                    .font(.system(size: 16, weight: .medium, design: AvailableFonts.design(for: font2)))
            }
            .foregroundStyle(Color("AppPrimary"))
        }
    }
}

struct ScoreRing: View {
    let score: Int
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppBackground").opacity(0.55), lineWidth: 3)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    AngularGradient(
                        colors: [Color("AppAccent"), Color("AppPrimary"), Color("AppAccent")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: size * 0.28, weight: .bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Project / tool / settings cells

struct ProjectCardCell: View {
    let project: DesignProject
    var pairCount: Int { project.pairIDs.count }

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: project.status == .approved ? "checkmark.seal.fill" : "folder.fill")

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(project.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    StatusChip(title: project.status.title, emphasized: project.status == .approved)
                }

                Text(project.notes.isEmpty ? "Add notes for brand context" : project.notes)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label("\(pairCount) pairs", systemImage: "textformat")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .surfaceCard()
    }
}

struct ToolCardCell: View {
    let title: String
    let detail: String
    let icon: String
    var badge: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: icon, size: 52)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let badge {
                        StatusChip(title: badge, emphasized: true)
                    }
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppBackground"))
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(DepthStyle.primaryButtonGradient)
                )
                .glowDepth()
        }
        .surfaceCard()
    }
}

struct SettingsRowCell: View {
    let title: String
    let systemImage: String
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(isDestructive ? Color.red : Color("AppBackground"))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            isDestructive
                            ? LinearGradient(colors: [Color.red.opacity(0.25), Color.red.opacity(0.12)], startPoint: .top, endPoint: .bottom)
                            : DepthStyle.primaryButtonGradient
                        )
                )
                .shadow(
                    color: isDestructive ? Color.red.opacity(0.2) : DepthStyle.glowShadowColor.opacity(0.45),
                    radius: 3,
                    y: 1
                )

            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

struct InsightTrendCell: View {
    let insight: Insight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(insight.category.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }
                Spacer()
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(Color("AppPrimary"))
            }

            Text(insight.detail)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(3)

            GeometryReader { geo in
                let values = insight.dataPoints
                let maxValue = max(values.max() ?? 1, 0.1)
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color("AppAccent"))
                            .frame(
                                width: max((geo.size.width - CGFloat(values.count - 1) * 4) / CGFloat(max(values.count, 1)), 4),
                                height: max(8, CGFloat(value / maxValue) * geo.size.height)
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 56)
        }
        .surfaceCard()
    }
}

struct ChecklistRowCell: View {
    let title: String
    let detail: String
    let isChecked: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isChecked ? Color("AppPrimary") : Color("AppTextSecondary"))
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .strikethrough(isChecked, color: Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .surfaceCard(padding: 14, highlighted: isChecked)
    }
}

struct StatsOverviewCell: View {
    let pairs: Int
    let minutes: Int
    let streak: Int
    let sessions: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderLabel(title: "Your Stats", subtitle: "Local activity on this device")

            HStack(spacing: 10) {
                MetricChip(title: "Pairs", value: "\(pairs)", icon: "textformat")
                MetricChip(title: "Minutes", value: "\(minutes)", icon: "clock.fill")
                MetricChip(title: "Streak", value: "\(streak)d", icon: "flame.fill")
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color("AppAccent"))
                Text("Sessions completed: \(sessions)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color("AppTextSecondary"))
                Spacer()
            }
        }
        .surfaceCard()
    }
}

struct FloatingActionBar: View {
    let primaryTitle: String
    var secondaryTitle: String? = nil
    let primaryAction: () -> Void
    var secondaryAction: (() -> Void)? = nil
    var primaryDisabled: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            if let secondaryTitle, let secondaryAction {
                Button {
                    FeedbackHelper.lightTap()
                    secondaryAction()
                } label: {
                    Text(secondaryTitle)
                        .secondaryButtonStyle()
                }
            }

            Button {
                FeedbackHelper.lightTap()
                primaryAction()
            } label: {
                Text(primaryTitle)
                    .frame(maxWidth: .infinity)
                    .bottomButtonStyle()
            }
            .disabled(primaryDisabled)
            .opacity(primaryDisabled ? 0.45 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(
            ZStack {
                DepthStyle.elevatedGradient
                DepthStyle.topSheen
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Color("AppPrimary").opacity(0.45), Color("AppPrimary").opacity(0.05), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 10)
                .allowsHitTesting(false)
            }
            .shadow(color: Color.black.opacity(0.35), radius: 10, y: -4)
        )
    }
}
