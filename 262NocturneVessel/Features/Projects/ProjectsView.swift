import SwiftUI

struct ProjectsView: View {
    var body: some View {
        NavigationStack {
            ProjectsRootView()
        }
        .transparentScreenChrome()
    }
}

struct ProjectsRootView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.tabBarClearance) private var tabBarClearance
    @State private var showCreate = false
    @State private var nameDraft = ""
    @State private var notesDraft = ""
    @State private var nameShake: CGFloat = 0
    @State private var errorText = ""

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 18) {
                        overview

                        if store.designProjects.isEmpty {
                            EmptyStateView(
                                symbolName: "folder.badge.plus",
                                message: "No project collections yet. Create Brand, Landing, or Pitch deck folders for your pairs.",
                                title: "Organize by project"
                            )
                        } else {
                            SectionHeaderLabel(
                                title: "Collections",
                                subtitle: "Draft and approved pair groups"
                            )

                            ForEach(store.designProjects) { project in
                                NavigationLink {
                                    ProjectDetailView(projectID: project.id)
                                } label: {
                                    ProjectCardCell(project: project)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        FeedbackHelper.lightTap()
                                        store.deleteProject(id: project.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                .clearScrollBackground()

                FloatingActionBar(
                    primaryTitle: "New Project Collection",
                    primaryAction: {
                        nameDraft = ""
                        notesDraft = ""
                        errorText = ""
                        showCreate = true
                    }
                )
                .padding(.bottom, tabBarClearance)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Projects")
        .navigationBarTitleDisplayMode(.inline)
        .appNavBarChrome()
        .sheet(isPresented: $showCreate) {
            createSheet
        }
    }

    private var overview: some View {
        let approved = store.designProjects.filter { $0.status == .approved }.count
        let linked = store.designProjects.reduce(0) { $0 + $1.pairIDs.count }
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(
                title: "Project board",
                subtitle: "Keep brand and campaign pairings separate"
            )
            HStack(spacing: 10) {
                MetricChip(title: "Projects", value: "\(store.designProjects.count)", icon: "folder.fill")
                MetricChip(title: "Approved", value: "\(approved)", icon: "checkmark.seal.fill")
                MetricChip(title: "Linked", value: "\(linked)", icon: "link")
            }
        }
        .surfaceCard()
    }

    private var createSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Project name")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            TextField("Brand A, Landing, Pitch deck…", text: $nameDraft)
                                .padding(12)
                                .background(Color("AppBackground").opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .shake(trigger: nameShake)
                            if !errorText.isEmpty {
                                Text(errorText)
                                    .font(.caption)
                                    .foregroundStyle(Color.red.opacity(0.9))
                            }
                            TextField("Notes", text: $notesDraft, axis: .vertical)
                                .lineLimit(2...5)
                                .padding(12)
                                .background(Color("AppBackground").opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        .surfaceCard()
                    }
                    .padding(16)
                }
                .clearScrollBackground()
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackHelper.lightTap()
                        showCreate = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createProject()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .appNavBarChrome()
        }
        .preferredColorScheme(.dark)
    }

    private func createProject() {
        let trimmed = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackHelper.warning()
            errorText = "Enter a project name."
            nameShake += 1
            return
        }
        FeedbackHelper.mediumTap()
        _ = store.addProject(name: trimmed, notes: notesDraft.trimmingCharacters(in: .whitespacesAndNewlines))
        FeedbackHelper.saveTick()
        showCreate = false
    }
}

struct ProjectDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    let projectID: String

    private var project: DesignProject? {
        store.designProjects.first(where: { $0.id == projectID })
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            if let project {
                ScrollView {
                    VStack(spacing: 16) {
                        statusControls(project)

                        SectionHeaderLabel(
                            title: "Linked pairs",
                            subtitle: "Toggle pairs that belong to this collection"
                        )

                        if store.fontPairs.isEmpty {
                            EmptyStateView(
                                symbolName: "textformat",
                                message: "Create font pairs first, then attach them here.",
                                title: "No pairs yet"
                            )
                        } else {
                            ForEach(store.fontPairs) { pair in
                                Button {
                                    FeedbackHelper.lightTap()
                                    store.togglePairInProject(projectID: project.id, pairID: pair.id)
                                } label: {
                                    HStack(spacing: 12) {
                                        PairGlyphView(font1: pair.font1, font2: pair.font2)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(pair.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color("AppTextPrimary"))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                            Text("\(pair.font1) + \(pair.font2)")
                                                .font(.caption)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                        }
                                        Spacer()
                                        Image(systemName: project.pairIDs.contains(pair.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(project.pairIDs.contains(pair.id) ? Color("AppPrimary") : Color("AppTextSecondary"))
                                    }
                                    .surfaceCard(padding: 12, highlighted: project.pairIDs.contains(pair.id))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .clearScrollBackground()
            } else {
                EmptyStateView(symbolName: "folder", message: "Project not found.", title: "Missing project")
                    .padding(16)
            }
        }
        .navigationTitle(project?.name ?? "Project")
        .navigationBarTitleDisplayMode(.inline)
        .appNavBarChrome()
    }

    private func statusControls(_ project: DesignProject) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(project.notes.isEmpty ? "No notes yet." : project.notes)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))

            Picker("Status", selection: Binding(
                get: { project.status },
                set: { newStatus in
                    var updated = project
                    updated.status = newStatus
                    store.updateProject(updated)
                    FeedbackHelper.lightTap()
                }
            )) {
                ForEach(ProjectStatus.allCases) { status in
                    Text(status.title).tag(status)
                }
            }
            .pickerStyle(.segmented)
        }
        .surfaceCard()
    }
}
