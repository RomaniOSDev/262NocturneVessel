import Foundation
import Combine

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private let defaults = UserDefaults.standard
    private var minuteTimer: AnyCancellable?

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let lastActivityDate {
                defaults.set(lastActivityDate.timeIntervalSince1970, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveCodable(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var fontPairs: [FontPair] {
        didSet { saveCodable(fontPairs, key: Keys.fontPairs) }
    }

    @Published var favoritePairs: Set<String> {
        didSet { saveCodable(Array(favoritePairs), key: Keys.favoritePairs) }
    }

    @Published var lastGeneratedInsightDate: Date? {
        didSet {
            if let lastGeneratedInsightDate {
                defaults.set(lastGeneratedInsightDate.timeIntervalSince1970, forKey: Keys.lastGeneratedInsightDate)
            } else {
                defaults.removeObject(forKey: Keys.lastGeneratedInsightDate)
            }
        }
    }

    @Published var trendFilters: [String] {
        didSet { saveCodable(trendFilters, key: Keys.trendFilters) }
    }

    @Published var recentInsights: [Insight] {
        didSet { saveCodable(recentInsights, key: Keys.recentInsights) }
    }

    @Published var designProjects: [DesignProject] {
        didSet { saveCodable(designProjects, key: Keys.designProjects) }
    }

    @Published var checklistStates: [PairChecklistState] {
        didSet { saveCodable(checklistStates, key: Keys.checklistStates) }
    }

    @Published var pendingAchievementBanner: AchievementDefinition?
    private var achievementQueue: [AchievementDefinition] = []
    private var isShowingBanner = false

    var itemsCreated: Int { fontPairs.count }

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let fontPairs = "fontPairs"
        static let favoritePairs = "favoritePairs"
        static let lastGeneratedInsightDate = "lastGeneratedInsightDate"
        static let trendFilters = "trendFilters"
        static let recentInsights = "recentInsights"
        static let lastSessionDay = "lastSessionDay"
        static let designProjects = "designProjects"
        static let checklistStates = "checklistStates"
    }

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)

        if defaults.object(forKey: Keys.lastActivityDate) != nil {
            lastActivityDate = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastActivityDate))
        } else {
            lastActivityDate = nil
        }

        if defaults.object(forKey: Keys.lastGeneratedInsightDate) != nil {
            lastGeneratedInsightDate = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastGeneratedInsightDate))
        } else {
            lastGeneratedInsightDate = nil
        }

        achievementsUnlocked = Self.loadCodable([String: Date].self, key: Keys.achievementsUnlocked, defaults: defaults) ?? [:]
        fontPairs = Self.loadCodable([FontPair].self, key: Keys.fontPairs, defaults: defaults) ?? []
        let favorites = Self.loadCodable([String].self, key: Keys.favoritePairs, defaults: defaults) ?? []
        favoritePairs = Set(favorites)
        trendFilters = Self.loadCodable([String].self, key: Keys.trendFilters, defaults: defaults) ?? ["week", "all"]
        recentInsights = Self.loadCodable([Insight].self, key: Keys.recentInsights, defaults: defaults) ?? []
        designProjects = Self.loadCodable([DesignProject].self, key: Keys.designProjects, defaults: defaults) ?? []
        checklistStates = Self.loadCodable([PairChecklistState].self, key: Keys.checklistStates, defaults: defaults) ?? []

        NotificationCenter.default.addObserver(
            forName: .dataReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reloadAfterReset()
        }
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordSessionIfNeeded()
        recordMeaningfulActivity()
    }

    func recordSessionIfNeeded() {
        let dayKey = Self.dayString(from: Date())
        let stored = defaults.string(forKey: Keys.lastSessionDay)
        guard stored != dayKey else { return }
        defaults.set(dayKey, forKey: Keys.lastSessionDay)
        totalSessionsCompleted += 1
        evaluateAchievements()
    }

    func recordMeaningfulActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 0 {
                // same day
            } else if diff == 1 {
                streakDays += 1
            } else if diff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = max(streakDays, 1)
        }

        lastActivityDate = Date()
        evaluateAchievements()
    }

    func startUsageTracking() {
        minuteTimer?.cancel()
        minuteTimer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.totalMinutesUsed += 1
            }
    }

    func pauseUsageTracking() {
        minuteTimer?.cancel()
        minuteTimer = nil
    }

    @discardableResult
    func addFontPair(
        name: String,
        description: String,
        font1: String,
        font2: String,
        scaleKind: TypeScaleKind = .ui
    ) -> FontPair {
        let category = AvailableFonts.category(for: font1)
        let pair = FontPair(
            name: name,
            pairDescription: description,
            font1: font1,
            font2: font2,
            category: category,
            sortOrder: fontPairs.count,
            scaleKind: scaleKind
        )
        fontPairs.append(pair)
        refreshInsights()
        recordMeaningfulActivity()
        evaluateAchievements()
        return pair
    }

    func updateFontPair(_ pair: FontPair) {
        guard let index = fontPairs.firstIndex(where: { $0.id == pair.id }) else { return }
        fontPairs[index] = pair
        refreshInsights()
        recordMeaningfulActivity()
    }

    func deleteFontPair(id: String) {
        fontPairs.removeAll { $0.id == id }
        favoritePairs.remove(id)
        checklistStates.removeAll { $0.pairID == id }
        for index in designProjects.indices {
            designProjects[index].pairIDs.removeAll { $0 == id }
            designProjects[index].updatedAt = Date()
        }
        refreshInsights()
        recordMeaningfulActivity()
    }

    func toggleFavorite(id: String) {
        if favoritePairs.contains(id) {
            favoritePairs.remove(id)
        } else {
            favoritePairs.insert(id)
        }
        recordMeaningfulActivity()
    }

    func reorderPairs(from source: IndexSet, to destination: Int) {
        var ordered = fontPairs.sorted { $0.sortOrder < $1.sortOrder }
        let moving = source.sorted().map { ordered[$0] }
        for index in source.sorted(by: >) {
            ordered.remove(at: index)
        }
        let insertIndex = min(destination, ordered.count)
        ordered.insert(contentsOf: moving, at: insertIndex)
        for index in ordered.indices {
            ordered[index].sortOrder = index
        }
        fontPairs = ordered
        recordMeaningfulActivity()
    }

    func applyPairOrder(_ pairs: [FontPair]) {
        var ordered = pairs
        for index in ordered.indices {
            ordered[index].sortOrder = index
        }
        fontPairs = ordered
        recordMeaningfulActivity()
    }

    func generateInsight() {
        refreshInsights()
        lastGeneratedInsightDate = Date()
        recordMeaningfulActivity()
        evaluateAchievements()
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()

        hasSeenOnboarding = false
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        fontPairs = []
        favoritePairs = []
        lastGeneratedInsightDate = nil
        trendFilters = ["week", "all"]
        recentInsights = []
        designProjects = []
        checklistStates = []
        pendingAchievementBanner = nil
        achievementQueue = []
        isShowingBanner = false

        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    // MARK: - Projects

    @discardableResult
    func addProject(name: String, notes: String = "") -> DesignProject {
        let project = DesignProject(name: name, notes: notes)
        designProjects.insert(project, at: 0)
        recordMeaningfulActivity()
        return project
    }

    func updateProject(_ project: DesignProject) {
        guard let index = designProjects.firstIndex(where: { $0.id == project.id }) else { return }
        var updated = project
        updated.updatedAt = Date()
        designProjects[index] = updated
        recordMeaningfulActivity()
    }

    func deleteProject(id: String) {
        designProjects.removeAll { $0.id == id }
        recordMeaningfulActivity()
    }

    func togglePairInProject(projectID: String, pairID: String) {
        guard let index = designProjects.firstIndex(where: { $0.id == projectID }) else { return }
        if designProjects[index].pairIDs.contains(pairID) {
            designProjects[index].pairIDs.removeAll { $0 == pairID }
        } else {
            designProjects[index].pairIDs.append(pairID)
        }
        designProjects[index].updatedAt = Date()
        recordMeaningfulActivity()
    }

    // MARK: - Checklist

    func checklistState(for pairID: String) -> PairChecklistState {
        if let existing = checklistStates.first(where: { $0.pairID == pairID }) {
            return existing
        }
        return PairChecklistState(pairID: pairID, checkedIDs: [])
    }

    func toggleChecklistItem(pairID: String, itemID: String) {
        var state = checklistState(for: pairID)
        var set = state.checkedSet
        if set.contains(itemID) {
            set.remove(itemID)
        } else {
            set.insert(itemID)
        }
        state.checkedSet = set
        if let index = checklistStates.firstIndex(where: { $0.pairID == pairID }) {
            checklistStates[index] = state
        } else {
            checklistStates.append(state)
        }
        recordMeaningfulActivity()
    }

    func evaluateAchievements() {
        for definition in Self.achievementDefinitions {
            guard definition.isUnlocked(self) else { continue }
            guard achievementsUnlocked[definition.id] == nil else { continue }
            achievementsUnlocked[definition.id] = Date()
            enqueueAchievementBanner(definition)
        }
    }

    private func enqueueAchievementBanner(_ definition: AchievementDefinition) {
        achievementQueue.append(definition)
        presentNextBannerIfNeeded()
    }

    private func presentNextBannerIfNeeded() {
        guard !isShowingBanner, let next = achievementQueue.first else { return }
        achievementQueue.removeFirst()
        isShowingBanner = true
        pendingAchievementBanner = next
        FeedbackHelper.success()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.pendingAchievementBanner = nil
            self?.isShowingBanner = false
            self?.presentNextBannerIfNeeded()
        }
    }

    private func refreshInsights() {
        guard !fontPairs.isEmpty else {
            recentInsights = []
            return
        }

        let categories = Dictionary(grouping: fontPairs, by: \.category)
        var insights: [Insight] = []

        for (category, pairs) in categories.sorted(by: { $0.key < $1.key }) {
            let points = Self.sparkline(for: pairs.count)
            insights.append(
                Insight(
                    title: "\(category.capitalized) Momentum",
                    detail: "\(pairs.count) saved pair\(pairs.count == 1 ? "" : "s") in \(category).",
                    category: category,
                    dataPoints: points
                )
            )
        }

        let favoritesCount = favoritePairs.count
        insights.append(
            Insight(
                title: "Favorite Focus",
                detail: favoritesCount == 0
                    ? "Mark pairs as favorites to track preferred combinations."
                    : "\(favoritesCount) favorite pair\(favoritesCount == 1 ? "" : "s") highlighted for quick reuse.",
                category: "favorites",
                dataPoints: Self.sparkline(for: max(favoritesCount, 1))
            )
        )

        let recent = fontPairs.sorted { $0.createdAt > $1.createdAt }.prefix(7)
        let weeklyPoints = (0..<7).map { offset -> Double in
            let day = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let count = recent.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: day) }.count
            return Double(count)
        }.reversed()

        insights.insert(
            Insight(
                title: "Weekly Pairing Pace",
                detail: "Your recent creation rhythm across the last seven days.",
                category: "week",
                dataPoints: Array(weeklyPoints)
            ),
            at: 0
        )

        recentInsights = insights
    }

    private func reloadAfterReset() {
        objectWillChange.send()
    }

    private func saveCodable<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func loadCodable<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func sparkline(for seed: Int) -> [Double] {
        let base = Double(max(seed, 1))
        return (0..<8).map { index in
            let wave = sin(Double(index) * 0.85 + base * 0.2)
            return max(0.2, (wave + 1.2) * (base * 0.35 + 0.4))
        }
    }

    static let achievementDefinitions: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_creation",
            title: "First Creation",
            detail: "Created your first font pair.",
            symbolName: "star.fill",
            isUnlocked: { $0.itemsCreated >= 1 }
        ),
        AchievementDefinition(
            id: "frequent_creator",
            title: "Frequent Creator",
            detail: "Created 10 font pairs.",
            symbolName: "square.stack.3d.up.fill",
            isUnlocked: { $0.itemsCreated >= 10 }
        ),
        AchievementDefinition(
            id: "dedicated_user",
            title: "Dedicated User",
            detail: "Completed 5 sessions in the app.",
            symbolName: "flame.fill",
            isUnlocked: { $0.totalSessionsCompleted >= 5 }
        ),
        AchievementDefinition(
            id: "typography_enthusiast",
            title: "Typography Enthusiast",
            detail: "Created 25 font pairs.",
            symbolName: "textformat",
            isUnlocked: { $0.itemsCreated >= 25 }
        ),
        AchievementDefinition(
            id: "streak_30",
            title: "+30 Days Streak",
            detail: "+30 consecutive days of activity.",
            symbolName: "calendar",
            isUnlocked: { $0.streakDays >= 30 }
        ),
        AchievementDefinition(
            id: "frequent_visitor",
            title: "Frequent Visitor",
            detail: "Opened the app on ten separate days.",
            symbolName: "person.fill.checkmark",
            isUnlocked: { $0.totalSessionsCompleted >= 10 }
        ),
        AchievementDefinition(
            id: "expert_designer",
            title: "Expert Designer",
            detail: "Created fifty different pairs.",
            symbolName: "paintbrush.pointed.fill",
            isUnlocked: { $0.itemsCreated >= 50 }
        ),
        AchievementDefinition(
            id: "persistent_explorer",
            title: "Persistent Explorer",
            detail: "+60 days of app access.",
            symbolName: "map.fill",
            isUnlocked: { $0.streakDays >= 60 }
        )
    ]
}
