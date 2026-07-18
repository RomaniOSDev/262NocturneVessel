import SwiftUI

struct MoodMatchView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedMoods: Set<MoodTag> = [.modern]
    @State private var showSavedBadge = false

    private var suggestions: [MoodSuggestion] {
        MoodMatcher.suggestions(for: selectedMoods, limit: 5)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 18) {
                    Text("Pick a brief mood")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(MoodTag.allCases) { mood in
                            Button {
                                FeedbackHelper.lightTap()
                                if selectedMoods.contains(mood) {
                                    if selectedMoods.count > 1 {
                                        selectedMoods.remove(mood)
                                    }
                                } else {
                                    selectedMoods.insert(mood)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: mood.symbolName)
                                        .font(.title3)
                                    Text(mood.title)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .foregroundStyle(
                                    selectedMoods.contains(mood)
                                    ? Color("AppBackground")
                                    : Color("AppTextPrimary")
                                )
                                .frame(maxWidth: .infinity, minHeight: 88)
                                .background(
                                    selectedMoods.contains(mood)
                                    ? Color("AppPrimary")
                                    : Color("AppSurface")
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    ForEach(suggestions) { suggestion in
                        suggestionCard(suggestion)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()

            if showSavedBadge {
                SuccessCheckBadge()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Mood Match")
        .navigationBarTitleDisplayMode(.inline)
        .appNavBarChrome()
    }

    private func suggestionCard(_ suggestion: MoodSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(suggestion.font1) + \(suggestion.font2)")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Spacer()
                Text(suggestion.mood.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppBackground"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("AppAccent"))
                    .clipShape(Capsule())
            }

            Text(suggestion.reason)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))

            LayoutCanvasView(
                content: .constant(.default),
                scale: TypeScaleAssignment.make(kind: .ui, headline: suggestion.font1, body: suggestion.font2),
                isEditable: false
            )

            Button {
                saveSuggestion(suggestion)
            } label: {
                Text("Save Pair")
                    .frame(maxWidth: .infinity)
                    .bottomButtonStyle()
            }
        }
        .padding(14)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func saveSuggestion(_ suggestion: MoodSuggestion) {
        FeedbackHelper.mediumTap()
        _ = store.addFontPair(
            name: "\(suggestion.mood.title): \(suggestion.font1) / \(suggestion.font2)",
            description: suggestion.reason,
            font1: suggestion.font1,
            font2: suggestion.font2,
            scaleKind: suggestion.mood == .technical ? .code : (suggestion.mood == .elegant ? .editorial : .ui)
        )
        FeedbackHelper.saveTick()
        showSavedBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSavedBadge = false
        }
    }
}
