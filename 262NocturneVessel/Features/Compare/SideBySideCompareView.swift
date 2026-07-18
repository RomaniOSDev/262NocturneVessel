import SwiftUI

struct SideBySideCompareView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var leftID: String = ""
    @State private var rightID: String = ""
    @State private var sharedContent = PreviewCanvasContent.default

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 18) {
                    if store.fontPairs.count < 2 {
                        EmptyStateView(
                            symbolName: "rectangle.split.2x1",
                            message: "Create at least two font pairs to compare them side by side."
                        )
                    } else {
                        pairPickers

                        Text("Shared sample copy")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        sharedCopyEditor

                        HStack(alignment: .top, spacing: 10) {
                            compareColumn(title: "A", pair: pair(for: leftID))
                            compareColumn(title: "B", pair: pair(for: rightID))
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
        .navigationTitle("Compare Pairs")
        .navigationBarTitleDisplayMode(.inline)
        .appNavBarChrome()
        .onAppear {
            if leftID.isEmpty {
                leftID = store.fontPairs.sorted { $0.sortOrder < $1.sortOrder }.first?.id ?? ""
            }
            if rightID.isEmpty {
                rightID = store.fontPairs.sorted { $0.sortOrder < $1.sortOrder }.dropFirst().first?.id ?? leftID
            }
        }
    }

    private var pairPickers: some View {
        VStack(spacing: 10) {
            Picker("Pair A", selection: $leftID) {
                ForEach(store.fontPairs) { pair in
                    Text(pair.name).tag(pair.id)
                }
            }
            .onChange(of: leftID) { _ in FeedbackHelper.lightTap() }

            Picker("Pair B", selection: $rightID) {
                ForEach(store.fontPairs) { pair in
                    Text(pair.name).tag(pair.id)
                }
            }
            .onChange(of: rightID) { _ in FeedbackHelper.lightTap() }
        }
        .padding(12)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var sharedCopyEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Headline", text: $sharedContent.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            TextField("Subtitle", text: $sharedContent.subtitle)
                .foregroundStyle(Color("AppTextPrimary"))
            TextField("Paragraph", text: $sharedContent.paragraph, axis: .vertical)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2...4)
            TextField("Button", text: $sharedContent.buttonTitle)
                .foregroundStyle(Color("AppTextPrimary"))
            TextField("Caption", text: $sharedContent.caption)
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .padding(12)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func compareColumn(title: String, pair: FontPair?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pair \(title)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))

            if let pair {
                Text(pair.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                LayoutCanvasView(
                    content: .constant(sharedContent),
                    scale: pair.typeScale,
                    isEditable: false
                )

                let report = ReadabilityAnalyzer.analyze(pair: pair)
                Text("Score \(report.score)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            } else {
                Text("Select a pair")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func pair(for id: String) -> FontPair? {
        store.fontPairs.first(where: { $0.id == id })
    }
}
