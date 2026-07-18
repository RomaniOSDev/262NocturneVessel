import Foundation
import Combine

final class FontPairDesignerViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var editingPair: FontPair?
    @Published var selectedPairID: String?
    @Published var pulsePairID: String?
    @Published var showSuccessBadge = false
    @Published var nameDraft = ""
    @Published var descriptionDraft = ""
    @Published var font1Draft = "SF Pro"
    @Published var font2Draft = "New York"
    @Published var scaleKindDraft: TypeScaleKind = .ui
    @Published var nameShake: CGFloat = 0
    @Published var validationMessage = ""

    private let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
    }

    var orderedPairs: [FontPair] {
        store.fontPairs.sorted { $0.sortOrder < $1.sortOrder }
    }

    func openAdd() {
        FeedbackHelper.lightTap()
        editingPair = nil
        nameDraft = ""
        descriptionDraft = ""
        font1Draft = "SF Pro"
        font2Draft = "New York"
        scaleKindDraft = .ui
        validationMessage = ""
        showingAddSheet = true
    }

    func openEdit(_ pair: FontPair) {
        FeedbackHelper.lightTap()
        editingPair = pair
        nameDraft = pair.name
        descriptionDraft = pair.pairDescription
        font1Draft = pair.font1
        font2Draft = pair.font2
        scaleKindDraft = pair.scaleKind
        validationMessage = ""
        showingAddSheet = true
    }

    func savePair() {
        let trimmed = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackHelper.warning()
            validationMessage = "Enter a name for this pair."
            nameShake += 1
            return
        }
        guard font1Draft != font2Draft else {
            FeedbackHelper.warning()
            validationMessage = "Choose two different fonts."
            nameShake += 1
            return
        }

        FeedbackHelper.mediumTap()

        if var existing = editingPair {
            existing.name = trimmed
            existing.pairDescription = descriptionDraft.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.font1 = font1Draft
            existing.font2 = font2Draft
            existing.category = AvailableFonts.category(for: font1Draft)
            existing.scaleKind = scaleKindDraft
            store.updateFontPair(existing)
            triggerSuccess(for: existing.id)
        } else {
            let pair = store.addFontPair(
                name: trimmed,
                description: descriptionDraft.trimmingCharacters(in: .whitespacesAndNewlines),
                font1: font1Draft,
                font2: font2Draft,
                scaleKind: scaleKindDraft
            )
            triggerSuccess(for: pair.id)
        }

        FeedbackHelper.saveTick()
        showingAddSheet = false
    }

    func deletePair(id: String) {
        FeedbackHelper.lightTap()
        store.deleteFontPair(id: id)
    }

    func toggleFavorite(id: String) {
        FeedbackHelper.lightTap()
        store.toggleFavorite(id: id)
    }

    func reorder(from source: IndexSet, to destination: Int) {
        store.reorderPairs(from: source, to: destination)
    }

    func generateInsight() {
        FeedbackHelper.mediumTap()
        store.generateInsight()
        FeedbackHelper.saveTick()
        showSuccessBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showSuccessBadge = false
        }
    }

    private func triggerSuccess(for id: String) {
        pulsePairID = id
        showSuccessBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.pulsePairID = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showSuccessBadge = false
        }
    }
}
