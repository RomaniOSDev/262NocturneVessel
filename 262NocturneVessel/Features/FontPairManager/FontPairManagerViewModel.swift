import Foundation
import Combine

final class FontPairManagerViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var editingPair: FontPair?
    @Published var nameDraft = ""
    @Published var descriptionDraft = ""
    @Published var font1Draft = "SF Pro"
    @Published var font2Draft = "New York"
    @Published var nameShake: CGFloat = 0
    @Published var validationMessage = ""
    @Published var expandedID: String?
    @Published var showSuccessBadge = false

    private let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
    }

    var pairs: [FontPair] {
        store.fontPairs.sorted { $0.createdAt > $1.createdAt }
    }

    func openAdd() {
        FeedbackHelper.lightTap()
        editingPair = nil
        nameDraft = ""
        descriptionDraft = ""
        font1Draft = "Helvetica Neue"
        font2Draft = "Georgia"
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
        validationMessage = ""
        showingAddSheet = true
    }

    func toggleExpand(_ id: String) {
        FeedbackHelper.lightTap()
        expandedID = expandedID == id ? nil : id
    }

    func savePair() {
        let trimmed = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackHelper.warning()
            validationMessage = "Enter a title for this set."
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
            store.updateFontPair(existing)
        } else {
            _ = store.addFontPair(
                name: trimmed,
                description: descriptionDraft.trimmingCharacters(in: .whitespacesAndNewlines),
                font1: font1Draft,
                font2: font2Draft
            )
        }

        FeedbackHelper.saveTick()
        showSuccessBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showSuccessBadge = false
        }
        showingAddSheet = false
    }

    func deletePair(id: String) {
        FeedbackHelper.lightTap()
        store.deleteFontPair(id: id)
    }
}
