import SwiftUI

struct FontPairManagerView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = FontPairManagerViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    if store.fontPairs.isEmpty {
                        ScrollView {
                            VStack(spacing: 20) {
                                ManagerEmptyIllustration()
                                    .frame(width: 160, height: 120)
                                    .padding(.top, 48)

                                EmptyStateView(
                                    symbolName: "textformat.alt",
                                    message: "No pairs saved yet. Tap below to add your first font combination."
                                )
                            }
                        }
                        .clearScrollBackground()
                    } else {
                        List {
                            ForEach(viewModel.pairs) { pair in
                                managerRow(pair)
                                    .listRowBackground(Color("AppSurface"))
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deletePair(id: pair.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .clearScrollBackground()
                    }

                    Button {
                        viewModel.openAdd()
                    } label: {
                        Text("Add New Pair")
                            .bottomButtonStyle()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                if viewModel.showSuccessBadge {
                    SuccessCheckBadge()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("Font Pair Manager")
            .navigationBarTitleDisplayMode(.inline)
            .appNavBarChrome()
            .sheet(isPresented: $viewModel.showingAddSheet) {
                managerEditorSheet
            }
        }
        .background(Color.clear)
    }

    private func managerRow(_ pair: FontPair) -> some View {
        Button {
            viewModel.toggleExpand(pair.id)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    PairThumbnail(font1: pair.font1, font2: pair.font2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pair.title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(pair.pairDescription.isEmpty ? "No description" : pair.pairDescription)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: viewModel.expandedID == pair.id ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Color("AppAccent"))
                }

                if viewModel.expandedID == pair.id {
                    VStack(alignment: .leading, spacing: 8) {
                        FontPreviewText(fontName: pair.font1, text: "Aa Bb Cc", role: .headline, size: 28)
                        FontPreviewText(fontName: pair.font2, text: "The quick brown fox jumps.", role: .body, size: 15)
                        Button("Edit Details") {
                            viewModel.openEdit(pair)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppPrimary"))
                        .frame(minHeight: 44)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private var managerEditorSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                Form {
                    Section {
                        TextField("Title", text: $viewModel.nameDraft)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: viewModel.nameShake)
                        if !viewModel.validationMessage.isEmpty {
                            Text(viewModel.validationMessage)
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.9))
                        }
                        TextField("Description", text: $viewModel.descriptionDraft)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Section("Fonts") {
                        Picker("Font 1", selection: $viewModel.font1Draft) {
                            ForEach(AvailableFonts.catalog, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                        Picker("Font 2", selection: $viewModel.font2Draft) {
                            ForEach(AvailableFonts.catalog, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(viewModel.editingPair == nil ? "Add New Pair" : "Edit Pair")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackHelper.lightTap()
                        viewModel.showingAddSheet = false
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

private struct PairThumbnail: View {
    let font1: String
    let font2: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("AppBackground"))
                .frame(width: 56, height: 56)
            VStack(spacing: 2) {
                Text("A")
                    .font(.system(size: 18, weight: .bold, design: AvailableFonts.design(for: font1)))
                Text("a")
                    .font(.system(size: 14, weight: .regular, design: AvailableFonts.design(for: font2)))
            }
            .foregroundStyle(Color("AppPrimary"))
        }
    }
}

private struct ManagerEmptyIllustration: View {
    var body: some View {
        Canvas { context, size in
            let left = CGRect(x: 10, y: 20, width: 60, height: 80)
            let right = CGRect(x: size.width - 70, y: 20, width: 60, height: 80)
            context.stroke(
                Path(roundedRect: left, cornerRadius: 8),
                with: .color(Color("AppAccent")),
                style: StrokeStyle(lineWidth: 2, dash: [5, 4])
            )
            context.stroke(
                Path(roundedRect: right, cornerRadius: 8),
                with: .color(Color("AppPrimary")),
                style: StrokeStyle(lineWidth: 2, dash: [5, 4])
            )
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: left.maxX + 4, y: size.height * 0.5))
                    path.addLine(to: CGPoint(x: right.minX - 4, y: size.height * 0.5))
                },
                with: .color(Color("AppTextSecondary")),
                lineWidth: 2
            )
        }
        .overlay {
            HStack(spacing: 48) {
                Text("Aa")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppPrimary").opacity(0.7))
                Text("Bb")
                    .font(.title3)
                    .foregroundStyle(Color("AppAccent").opacity(0.7))
            }
        }
    }
}
