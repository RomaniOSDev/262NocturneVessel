import SwiftUI

struct FontPairDesignerView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.tabBarClearance) private var tabBarClearance
    @StateObject private var viewModel = FontPairDesignerViewModel()
    @State private var isReordering = false
    @State private var path = NavigationPath()

    private let featureCards: [(title: String, detail: String, image: String, badge: String, dest: HomeFeatureDestination)] = [
        ("Mood Match", "Turn a brief into ready pairings", "HomeMood", "Brief", .mood),
        ("Compare", "Judge two pairs with shared copy", "HomeCompare", "Review", .compare),
        ("Role Library", "Display, UI, Editorial, Code scales", "HomeCanvas", "Scale", .roles),
        ("Projects", "Group pairs by brand or campaign", "HomeProjects", "Organize", .projects)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 18) {
                            HomeHeroBanner(
                                onCreate: { viewModel.openAdd() },
                                onExplore: {
                                    FeedbackHelper.lightTap()
                                    path.append(HomeFeatureDestination.mood)
                                }
                            )

                            statsRow

                            SectionHeaderLabel(
                                title: "Studio shortcuts",
                                subtitle: "Jump into the tools designers actually use"
                            )

                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                                spacing: 12
                            ) {
                                ForEach(Array(featureCards.prefix(2).enumerated()), id: \.offset) { _, card in
                                    Button {
                                        FeedbackHelper.lightTap()
                                        path.append(card.dest)
                                    } label: {
                                        HomeImageFeatureCard(
                                            title: card.title,
                                            detail: card.detail,
                                            imageName: card.image
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            ForEach(Array(featureCards.suffix(2).enumerated()), id: \.offset) { _, card in
                                Button {
                                    FeedbackHelper.lightTap()
                                    path.append(card.dest)
                                } label: {
                                    HomeWideImageCard(
                                        title: card.title,
                                        detail: card.detail,
                                        imageName: card.image,
                                        badge: card.badge
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            librarySection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                    .clearScrollBackground()

                    FloatingActionBar(
                        primaryTitle: store.fontPairs.isEmpty ? "Create First Pair" : "Generate Insight",
                        secondaryTitle: store.fontPairs.isEmpty ? nil : "Add Pair",
                        primaryAction: {
                            if store.fontPairs.isEmpty {
                                viewModel.openAdd()
                            } else {
                                viewModel.generateInsight()
                            }
                        },
                        secondaryAction: { viewModel.openAdd() },
                        primaryDisabled: false
                    )
                    .padding(.bottom, tabBarClearance)
                }

                if viewModel.showSuccessBadge {
                    SuccessCheckBadge()
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.showSuccessBadge)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        FeedbackHelper.lightTap()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isReordering.toggle()
                        }
                    } label: {
                        Text(isReordering ? "Done" : "Reorder")
                            .foregroundStyle(Color("AppPrimary"))
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .disabled(store.fontPairs.count < 2)
                    .opacity(store.fontPairs.count < 2 ? 0.35 : 1)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.openAdd()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("AppPrimary"))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Add Pair")
                }
            }
            .appNavBarChrome()
            .sheet(isPresented: $viewModel.showingAddSheet) {
                FontPairEditorSheet(viewModel: viewModel)
            }
            .navigationDestination(for: HomeFeatureDestination.self) { destination in
                featureDestination(destination)
                    .hidesTabBar()
            }
        }
        .transparentScreenChrome()
    }

    private var statsRow: some View {
        let favorites = store.favoritePairs.count
        let avgScore: Int = {
            guard !store.fontPairs.isEmpty else { return 0 }
            let total = store.fontPairs.reduce(0) { $0 + ReadabilityAnalyzer.analyze(pair: $1).score }
            return total / store.fontPairs.count
        }()

        return HStack(spacing: 10) {
            MetricChip(title: "Pairs", value: "\(store.itemsCreated)", icon: "square.stack.3d.up.fill")
            MetricChip(title: "Favorites", value: "\(favorites)", icon: "star.fill")
            MetricChip(title: "Avg score", value: store.fontPairs.isEmpty ? "—" : "\(avgScore)", icon: "gauge.medium")
        }
        .surfaceCard(padding: 12)
    }

    @ViewBuilder
    private var librarySection: some View {
        SectionHeaderLabel(
            title: "Your pairs",
            subtitle: isReordering ? "Use arrows to reorder" : "Open a card to edit the live layout canvas"
        )

        if store.fontPairs.isEmpty {
            EmptyStateView(
                symbolName: "text.badge.plus",
                message: "No Font Pairs Yet! Tap '+' to start creating",
                title: "Build your first pair"
            )
        } else {
            ForEach(viewModel.orderedPairs) { pair in
                pairCell(pair)
            }
        }
    }

    @ViewBuilder
    private func pairCell(_ pair: FontPair) -> some View {
        let score = ReadabilityAnalyzer.analyze(pair: pair).score

        VStack(spacing: 8) {
            NavigationLink {
                PairWorkspaceView(pairID: pair.id)
                    .hidesTabBar()
            } label: {
                PairCardCell(
                    pair: pair,
                    isFavorite: store.favoritePairs.contains(pair.id),
                    isHighlighted: viewModel.pulsePairID == pair.id,
                    score: score,
                    onFavorite: { viewModel.toggleFavorite(id: pair.id) }
                )
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button {
                    viewModel.openEdit(pair)
                } label: {
                    Label("Edit Details", systemImage: "pencil")
                }
                Button {
                    viewModel.toggleFavorite(id: pair.id)
                } label: {
                    Label(
                        store.favoritePairs.contains(pair.id) ? "Remove Favorite" : "Favorite",
                        systemImage: "star"
                    )
                }
                Button(role: .destructive) {
                    viewModel.deletePair(id: pair.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }

            if isReordering {
                HStack(spacing: 10) {
                    Button {
                        movePair(pair, direction: -1)
                    } label: {
                        Label("Up", systemImage: "arrow.up")
                            .frame(maxWidth: .infinity)
                            .secondaryButtonStyle()
                    }
                    Button {
                        movePair(pair, direction: 1)
                    } label: {
                        Label("Down", systemImage: "arrow.down")
                            .frame(maxWidth: .infinity)
                            .secondaryButtonStyle()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func featureDestination(_ destination: HomeFeatureDestination) -> some View {
        switch destination {
        case .mood:
            MoodMatchView()
        case .compare:
            SideBySideCompareView()
        case .roles:
            RoleLibraryView()
        case .projects:
            ProjectsRootView()
        }
    }

    private func movePair(_ pair: FontPair, direction: Int) {
        FeedbackHelper.lightTap()
        var ordered = viewModel.orderedPairs
        guard let index = ordered.firstIndex(where: { $0.id == pair.id }) else { return }
        let newIndex = index + direction
        guard ordered.indices.contains(newIndex) else { return }
        ordered.swapAt(index, newIndex)
        store.applyPairOrder(ordered)
    }
}

struct FontPairEditorSheet: View {
    @ObservedObject var viewModel: FontPairDesignerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Details")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            TextField("Pair name", text: $viewModel.nameDraft)
                                .padding(12)
                                .background(Color("AppBackground").opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .shake(trigger: viewModel.nameShake)
                            if !viewModel.validationMessage.isEmpty {
                                Text(viewModel.validationMessage)
                                    .font(.caption)
                                    .foregroundStyle(Color.red.opacity(0.9))
                            }
                            TextField("Short description", text: $viewModel.descriptionDraft)
                                .padding(12)
                                .background(Color("AppBackground").opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        .surfaceCard()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Fonts")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Picker("Primary font", selection: $viewModel.font1Draft) {
                                ForEach(AvailableFonts.catalog, id: \.name) { item in
                                    Text(item.name).tag(item.name)
                                }
                            }
                            .tint(Color("AppPrimary"))
                            Picker("Secondary font", selection: $viewModel.font2Draft) {
                                ForEach(AvailableFonts.catalog, id: \.name) { item in
                                    Text(item.name).tag(item.name)
                                }
                            }
                            .tint(Color("AppPrimary"))
                        }
                        .surfaceCard()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Type scale")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            ForEach(TypeScaleKind.allCases) { kind in
                                Button {
                                    FeedbackHelper.lightTap()
                                    viewModel.scaleKindDraft = kind
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(kind.title)
                                                .font(.subheadline.weight(.bold))
                                                .foregroundStyle(Color("AppTextPrimary"))
                                            Text(kind.detail)
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                                .lineLimit(2)
                                        }
                                        Spacer()
                                        if viewModel.scaleKindDraft == kind {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color("AppPrimary"))
                                        }
                                    }
                                    .padding(10)
                                    .background(
                                        viewModel.scaleKindDraft == kind
                                        ? Color("AppPrimary").opacity(0.14)
                                        : Color("AppBackground").opacity(0.35)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .surfaceCard()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Live Preview")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            FontPreviewText(fontName: viewModel.font1Draft, text: "Preview Headline", role: .headline)
                            FontPreviewText(fontName: viewModel.font2Draft, text: "Preview body text for balance and contrast.", role: .body, size: 16)
                        }
                        .surfaceCard()
                    }
                    .padding(16)
                }
                .clearScrollBackground()
            }
            .navigationTitle(viewModel.editingPair == nil ? "Add Pair" : "Edit Pair")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackHelper.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.savePair()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .appNavBarChrome()
        }
        .preferredColorScheme(.dark)
    }
}
