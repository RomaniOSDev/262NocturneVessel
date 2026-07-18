import SwiftUI

struct RoleLibraryView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedKind: TypeScaleKind = .ui
    @State private var headline = "SF Pro"
    @State private var bodyFont = "New York"
    @State private var showSavedBadge = false

    private var assignment: TypeScaleAssignment {
        TypeScaleAssignment.make(kind: selectedKind, headline: headline, body: bodyFont)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 18) {
                    Text("Type scale roles")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(TypeScaleKind.allCases) { kind in
                        Button {
                            FeedbackHelper.lightTap()
                            selectedKind = kind
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(kind.title)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text(kind.detail)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                if selectedKind == kind {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color("AppPrimary"))
                                }
                            }
                            .padding(12)
                            .background(selectedKind == kind ? Color("AppPrimary").opacity(0.15) : Color("AppSurface"))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Picker("Headline", selection: $headline) {
                            ForEach(AvailableFonts.catalog, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                        Picker("Body", selection: $bodyFont) {
                            ForEach(AvailableFonts.catalog, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    roleRows

                    LayoutCanvasView(
                        content: .constant(.default),
                        scale: assignment,
                        isEditable: false
                    )

                    Button {
                        saveScale()
                    } label: {
                        Text("Save as Pair with Scale")
                            .frame(maxWidth: .infinity)
                            .bottomButtonStyle()
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
        .navigationTitle("Role Library")
        .navigationBarTitleDisplayMode(.inline)
        .appNavBarChrome()
    }

    private var roleRows: some View {
        VStack(spacing: 8) {
            roleRow(title: "H1", font: assignment.h1Font, size: assignment.sizes.h1)
            roleRow(title: "H2", font: assignment.h2Font, size: assignment.sizes.h2)
            roleRow(title: "Body", font: assignment.bodyFont, size: assignment.sizes.body)
            roleRow(title: "Button", font: assignment.buttonFont, size: assignment.sizes.button)
            roleRow(title: "Caption", font: assignment.captionFont, size: assignment.sizes.caption)
        }
        .padding(12)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func roleRow(title: String, font: String, size: CGFloat) -> some View {
        HStack {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 58, alignment: .leading)
            Text(font)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text("\(Int(size))pt")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(minHeight: 36)
    }

    private func saveScale() {
        FeedbackHelper.mediumTap()
        _ = store.addFontPair(
            name: "\(selectedKind.title) Scale",
            description: "Saved from Role Library · \(selectedKind.detail)",
            font1: headline,
            font2: bodyFont,
            scaleKind: selectedKind
        )
        FeedbackHelper.saveTick()
        showSavedBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSavedBadge = false
        }
    }
}
