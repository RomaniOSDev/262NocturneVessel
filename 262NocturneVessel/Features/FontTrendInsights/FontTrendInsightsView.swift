import SwiftUI
import Charts

struct FontTrendInsightsView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.tabBarClearance) private var tabBarClearance
    @StateObject private var viewModel = FontTrendInsightsViewModel()
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppBackgroundView()

                if store.fontPairs.isEmpty {
                    ScrollView {
                        VStack(spacing: 18) {
                            InsightsEmptyIllustration()
                                .frame(width: 180, height: 140)
                                .padding(.top, 48)

                            EmptyStateView(
                                symbolName: "magnifyingglass",
                                message: "Track Your Font Pair Trends",
                                title: "Insights unlock with pairs"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .tabBarContentInset(extra: 88)
                    }
                    .clearScrollBackground()
                } else {
                    ScrollView {
                        VStack(spacing: 18) {
                            filterControls

                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredInsights()) { insight in
                                    Button {
                                        FeedbackHelper.lightTap()
                                        viewModel.selectedInsight = insight
                                    } label: {
                                        InsightTrendCell(insight: insight)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button {
                                            viewModel.shareInsight(insight)
                                        } label: {
                                            Label("Share Insight", systemImage: "square.and.arrow.up")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .tabBarContentInset(extra: 88)
                    }
                    .clearScrollBackground()
                }

                Button {
                    viewModel.discoverFonts()
                    showCreateSheet = true
                } label: {
                    Label("Discover Fonts", systemImage: "plus.magnifyingglass")
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .background(
                            Capsule().fill(DepthStyle.primaryButtonGradient)
                        )
                        .foregroundStyle(Color("AppBackground"))
                        .glowDepth()
                }
                .padding(.trailing, 20)
                .padding(.bottom, max(20, tabBarClearance + 12))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Font Trend Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackHelper.lightTap()
                        viewModel.showingSearch.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color("AppPrimary"))
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .appNavBarChrome()
            .safeAreaInset(edge: .top) {
                if viewModel.showingSearch {
                    TextField("Search insights", text: $viewModel.searchText)
                        .padding(12)
                        .background(Color("AppSurface"))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            }
            .sheet(item: $viewModel.selectedInsight) { insight in
                InsightDetailSheet(insight: insight)
            }
            .sheet(isPresented: $showCreateSheet) {
                DiscoverPairSheet()
            }
            .onAppear {
                viewModel.loadFilters()
                if store.recentInsights.isEmpty && !store.fontPairs.isEmpty {
                    store.generateInsight()
                }
            }
            .onChange(of: viewModel.dateRange) { _ in
                viewModel.persistFilters()
            }
            .onChange(of: viewModel.categoryFilter) { _ in
                viewModel.persistFilters()
            }
        }
        .transparentScreenChrome()
    }

    private var filterControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: "Trend filters", subtitle: "Slice analytics by time and category")

            Picker("Range", selection: $viewModel.dateRange) {
                ForEach(FontTrendInsightsViewModel.DateRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FontTrendInsightsViewModel.CategoryFilter.allCases) { filter in
                        Button {
                            FeedbackHelper.lightTap()
                            viewModel.categoryFilter = filter
                        } label: {
                            Text(filter.title)
                                .font(.caption.weight(.bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(minHeight: 44)
                                .background(
                                    viewModel.categoryFilter == filter
                                    ? Color("AppPrimary")
                                    : Color("AppBackground").opacity(0.4)
                                )
                                .foregroundStyle(
                                    viewModel.categoryFilter == filter
                                    ? Color("AppBackground")
                                    : Color("AppTextPrimary")
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .surfaceCard()
    }
}

private struct InsightDetailSheet: View {
    let insight: Insight
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(insight.detail)
                            .foregroundStyle(Color("AppTextSecondary"))

                        Chart(Array(insight.dataPoints.enumerated()), id: \.offset) { item in
                            BarMark(
                                x: .value("Index", item.offset),
                                y: .value("Value", item.element)
                            )
                            .foregroundStyle(Color("AppPrimary"))
                        }
                        .frame(height: 180)

                        Text("Category: \(insight.category)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .padding(20)
                }
                .clearScrollBackground()
            }
            .navigationTitle(insight.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackHelper.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .appNavBarChrome()
        }
        .preferredColorScheme(.dark)
    }
}

private struct DiscoverPairSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var font1 = "Avenir Next"
    @State private var font2 = "Didot"
    @State private var shake: CGFloat = 0
    @State private var errorText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                Form {
                    Section {
                        TextField("Pair name", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shake)
                        if !errorText.isEmpty {
                            Text(errorText)
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.9))
                        }
                    }
                    Section("Suggested Pairing") {
                        Picker("Primary", selection: $font1) {
                            ForEach(AvailableFonts.catalog, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                        Picker("Secondary", selection: $font2) {
                            ForEach(AvailableFonts.catalog, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Discover Fonts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackHelper.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .appNavBarChrome()
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackHelper.warning()
            errorText = "Enter a name for this pair."
            shake += 1
            return
        }
        guard font1 != font2 else {
            FeedbackHelper.warning()
            errorText = "Choose two different fonts."
            shake += 1
            return
        }
        FeedbackHelper.mediumTap()
        _ = store.addFontPair(name: trimmed, description: "Discovered pairing", font1: font1, font2: font2)
        store.generateInsight()
        FeedbackHelper.saveTick()
        dismiss()
    }
}

private struct InsightsEmptyIllustration: View {
    var body: some View {
        Canvas { context, size in
            context.stroke(
                Path(ellipseIn: CGRect(x: 20, y: 30, width: 70, height: 90)),
                with: .color(Color("AppAccent")),
                style: StrokeStyle(lineWidth: 2, dash: [4, 3])
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: size.width - 90, y: 20, width: 70, height: 90)),
                with: .color(Color("AppPrimary")),
                style: StrokeStyle(lineWidth: 2, dash: [4, 3])
            )
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: 40, y: size.height - 20))
                    path.addCurve(
                        to: CGPoint(x: size.width - 40, y: size.height - 30),
                        control1: CGPoint(x: size.width * 0.35, y: size.height - 60),
                        control2: CGPoint(x: size.width * 0.65, y: size.height)
                    )
                },
                with: .color(Color("AppTextSecondary")),
                lineWidth: 2
            )
        }
        .overlay {
            HStack(spacing: 36) {
                Text("T")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(Color("AppPrimary").opacity(0.75))
                Text("t")
                    .font(.system(size: 36, weight: .light, design: .rounded))
                    .foregroundStyle(Color("AppAccent").opacity(0.75))
            }
        }
    }
}
