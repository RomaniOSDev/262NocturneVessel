import SwiftUI

struct PairWorkspaceView: View {
    @EnvironmentObject private var store: AppDataStore
    let pairID: String

    @State private var selectedSection = 0
    @State private var showExportSheet = false
    @State private var exportItems: [Any] = []
    @State private var draft: FontPair?
    @State private var showSavedBadge = false

    var body: some View {
        ZStack {
            AppBackgroundView()

            if draft != nil {
                ScrollView {
                    VStack(spacing: 18) {
                        Picker("Section", selection: $selectedSection) {
                            Text("Canvas").tag(0)
                            Text("Score").tag(1)
                            Text("Export").tag(2)
                            Text("Checklist").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedSection) { _ in
                            FeedbackHelper.lightTap()
                        }

                        sectionContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
                .clearScrollBackground()
            } else {
                EmptyStateView(symbolName: "questionmark.circle", message: "This pair is no longer available.")
                    .padding(20)
            }

            if showSavedBadge {
                SuccessCheckBadge()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(draft?.name ?? "Workspace")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveDraft()
                }
                .foregroundStyle(Color("AppPrimary"))
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .appNavBarChrome()
        .onAppear {
            draft = store.fontPairs.first(where: { $0.id == pairID })
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheetView(items: exportItems) {
                FeedbackHelper.saveTick()
            }
        }
    }

    @ViewBuilder
    private var sectionContent: some View {
        if let draft {
            switch selectedSection {
            case 0:
                canvasSection
            case 1:
                ReadabilityScoreCard(report: ReadabilityAnalyzer.analyze(pair: draft))
                scalePicker
            case 2:
                ExportPanelView(pair: draft) { items in
                    exportItems = items
                    showExportSheet = true
                }
            default:
                PairChecklistSection(pairID: draft.id)
            }
        }
    }

    private var canvasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live layout canvas")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            if draft != nil {
                LayoutCanvasView(
                    content: Binding(
                        get: { self.draft?.canvas ?? .default },
                        set: { newValue in
                            guard var current = self.draft else { return }
                            current.canvas = newValue
                            self.draft = current
                        }
                    ),
                    scale: draft?.typeScale ?? TypeScaleAssignment.make(kind: .ui, headline: "SF Pro", body: "New York"),
                    isEditable: true
                )
            }

            Text("Edit any line to preview hierarchy in context.")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }

    private var scalePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Role library preset")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            ForEach(TypeScaleKind.allCases) { kind in
                Button {
                    FeedbackHelper.lightTap()
                    guard var current = draft else { return }
                    current.scaleKind = kind
                    draft = current
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(kind.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(kind.detail)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        if draft?.scaleKind == kind {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .padding(12)
                    .background(
                        draft?.scaleKind == kind
                        ? Color("AppPrimary").opacity(0.15)
                        : Color("AppSurface")
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func saveDraft() {
        guard let draft else { return }
        FeedbackHelper.mediumTap()
        store.updateFontPair(draft)
        FeedbackHelper.saveTick()
        showSavedBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSavedBadge = false
        }
    }
}

struct PairChecklistSection: View {
    @EnvironmentObject private var store: AppDataStore
    let pairID: String

    var body: some View {
        let state = store.checklistState(for: pairID)
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(
                title: "Delivery checklist",
                subtitle: "\(state.checkedIDs.count) of \(TypographyChecklistCatalog.items.count) complete"
            )

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("AppBackground").opacity(0.45))
                    Capsule()
                        .fill(Color("AppAccent"))
                        .frame(width: geo.size.width * CGFloat(state.checkedIDs.count) / CGFloat(max(TypographyChecklistCatalog.items.count, 1)))
                }
            }
            .frame(height: 8)
            .padding(.bottom, 4)

            ForEach(TypographyChecklistCatalog.items) { item in
                Button {
                    FeedbackHelper.lightTap()
                    store.toggleChecklistItem(pairID: pairID, itemID: item.id)
                } label: {
                    ChecklistRowCell(
                        title: item.title,
                        detail: item.detail,
                        isChecked: state.checkedSet.contains(item.id)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
