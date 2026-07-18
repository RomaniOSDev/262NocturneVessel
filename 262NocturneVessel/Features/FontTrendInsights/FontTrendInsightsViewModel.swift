import Foundation
import Combine

final class FontTrendInsightsViewModel: ObservableObject {
    enum DateRange: String, CaseIterable, Identifiable {
        case week
        case month
        case year

        var id: String { rawValue }

        var title: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            }
        }
    }

    enum CategoryFilter: String, CaseIterable, Identifiable {
        case all
        case serif
        case sansSerif = "sans-serif"
        case monospace
        case display

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all: return "All"
            case .serif: return "Serif"
            case .sansSerif: return "Sans"
            case .monospace: return "Mono"
            case .display: return "Display"
            }
        }
    }

    @Published var dateRange: DateRange = .week
    @Published var categoryFilter: CategoryFilter = .all
    @Published var selectedInsight: Insight?
    @Published var showingSearch = false
    @Published var searchText = ""
    @Published var navigateToCreate = false

    private let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
    }

    func filteredInsights() -> [Insight] {
        var items = store.recentInsights

        if categoryFilter != .all {
            let shared = items.filter { $0.category == "week" || $0.category == "favorites" }
            let categoryItems = items.filter { $0.category == categoryFilter.rawValue }
            items = shared + categoryItems
        }

        let scale: Double
        switch dateRange {
        case .week: scale = 1.0
        case .month: scale = 1.15
        case .year: scale = 1.35
        }

        if scale != 1.0 {
            items = items.map { insight in
                var copy = insight
                copy.dataPoints = insight.dataPoints.map { $0 * scale }
                return copy
            }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            items = items.filter {
                $0.title.lowercased().contains(query) || $0.detail.lowercased().contains(query)
            }
        }

        return items
    }

    func persistFilters() {
        store.trendFilters = [dateRange.rawValue, categoryFilter.rawValue]
    }

    func loadFilters() {
        if let range = store.trendFilters.first, let parsed = DateRange(rawValue: range) {
            dateRange = parsed
        }
        if store.trendFilters.count > 1, let parsed = CategoryFilter(rawValue: store.trendFilters[1]) {
            categoryFilter = parsed
        }
    }

    func discoverFonts() {
        FeedbackHelper.lightTap()
        navigateToCreate = true
    }

    func shareInsight(_ insight: Insight) {
        FeedbackHelper.tick()
        selectedInsight = insight
    }
}
