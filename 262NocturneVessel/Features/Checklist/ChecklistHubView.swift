import SwiftUI

struct ChecklistHubView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderLabel(
                            title: "Handoff readiness",
                            subtitle: "Run the checklist before exporting a pair"
                        )
                        if !store.fontPairs.isEmpty {
                            let totalChecks = store.fontPairs.reduce(0) { $0 + store.checklistState(for: $1.id).checkedIDs.count }
                            let maxChecks = store.fontPairs.count * TypographyChecklistCatalog.items.count
                            MetricChip(
                                title: "Checks done",
                                value: "\(totalChecks)/\(maxChecks)",
                                icon: "checklist"
                            )
                        }
                    }
                    .surfaceCard()

                    if store.fontPairs.isEmpty {
                        EmptyStateView(
                            symbolName: "checklist",
                            message: "Save a font pair first, then run the delivery checklist before handoff.",
                            title: "Nothing to review"
                        )
                    } else {
                        ForEach(store.fontPairs.sorted(by: { $0.createdAt > $1.createdAt })) { pair in
                            let state = store.checklistState(for: pair.id)
                            NavigationLink {
                                ScrollView {
                                    PairChecklistSection(pairID: pair.id)
                                        .padding(16)
                                }
                                .clearScrollBackground()
                                .background {
                                    AppBackgroundView()
                                }
                                .navigationTitle(pair.name)
                                .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                HStack(spacing: 12) {
                                    PairGlyphView(font1: pair.font1, font2: pair.font2)
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(pair.name)
                                            .font(.headline.weight(.bold))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                        Text("\(state.checkedIDs.count)/\(TypographyChecklistCatalog.items.count) checked")
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule().fill(Color("AppBackground").opacity(0.45))
                                                Capsule()
                                                    .fill(Color("AppAccent"))
                                                    .frame(width: geo.size.width * CGFloat(state.checkedIDs.count) / CGFloat(max(TypographyChecklistCatalog.items.count, 1)))
                                            }
                                        }
                                        .frame(height: 6)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                                .surfaceCard(padding: 14)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Delivery Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .appNavBarChrome()
    }
}
