import Foundation
import SwiftUI

struct FontPair: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var pairDescription: String
    var font1: String
    var font2: String
    var category: String
    var createdAt: Date
    var sortOrder: Int
    var scaleKind: TypeScaleKind
    var canvas: PreviewCanvasContent

    var title: String { name }

    var typeScale: TypeScaleAssignment {
        TypeScaleAssignment.make(kind: scaleKind, headline: font1, body: font2)
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        pairDescription: String = "",
        font1: String,
        font2: String,
        category: String = "sans-serif",
        createdAt: Date = Date(),
        sortOrder: Int = 0,
        scaleKind: TypeScaleKind = .ui,
        canvas: PreviewCanvasContent = .default
    ) {
        self.id = id
        self.name = name
        self.pairDescription = pairDescription
        self.font1 = font1
        self.font2 = font2
        self.category = category
        self.createdAt = createdAt
        self.sortOrder = sortOrder
        self.scaleKind = scaleKind
        self.canvas = canvas
    }

    enum CodingKeys: String, CodingKey {
        case id, name, pairDescription, font1, font2, category, createdAt, sortOrder, scaleKind, canvas
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        pairDescription = try container.decodeIfPresent(String.self, forKey: .pairDescription) ?? ""
        font1 = try container.decode(String.self, forKey: .font1)
        font2 = try container.decode(String.self, forKey: .font2)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "sans-serif"
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        scaleKind = try container.decodeIfPresent(TypeScaleKind.self, forKey: .scaleKind) ?? .ui
        canvas = try container.decodeIfPresent(PreviewCanvasContent.self, forKey: .canvas) ?? .default
    }
}

struct Insight: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var detail: String
    var category: String
    var dataPoints: [Double]
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        detail: String,
        category: String,
        dataPoints: [Double],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.category = category
        self.dataPoints = dataPoints
        self.createdAt = createdAt
    }
}

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbolName: String
    let isUnlocked: (AppDataStore) -> Bool
}

enum AvailableFonts {
    static let catalog: [(name: String, category: String)] = [
        ("SF Pro", "sans-serif"),
        ("SF Pro Rounded", "sans-serif"),
        ("New York", "serif"),
        ("Georgia", "serif"),
        ("Times New Roman", "serif"),
        ("Helvetica Neue", "sans-serif"),
        ("Avenir Next", "sans-serif"),
        ("Futura", "sans-serif"),
        ("Gill Sans", "sans-serif"),
        ("Palatino", "serif"),
        ("Courier New", "monospace"),
        ("Menlo", "monospace"),
        ("American Typewriter", "serif"),
        ("Optima", "serif"),
        ("Baskerville", "serif"),
        ("Didot", "serif"),
        ("Copperplate", "display"),
        ("Impact", "display"),
        ("Verdana", "sans-serif"),
        ("Trebuchet MS", "sans-serif")
    ]

    static func category(for fontName: String) -> String {
        catalog.first(where: { $0.name == fontName })?.category ?? "sans-serif"
    }

    static func design(for fontName: String) -> Font.Design {
        switch category(for: fontName) {
        case "serif": return .serif
        case "monospace": return .monospaced
        case "display": return .default
        default: return fontName.contains("Rounded") ? .rounded : .default
        }
    }

    static func weight(for role: FontRole) -> Font.Weight {
        switch role {
        case .headline: return .bold
        case .subtitle: return .semibold
        case .body: return .regular
        case .button: return .semibold
        case .caption: return .medium
        }
    }

    static func cssStack(for fontName: String) -> String {
        let category = category(for: fontName)
        switch category {
        case "serif":
            return "\"\(fontName)\", \"Times New Roman\", Times, serif"
        case "monospace":
            return "\"\(fontName)\", Menlo, Monaco, monospace"
        case "display":
            return "\"\(fontName)\", Impact, Haettenschweiler, sans-serif"
        default:
            return "\"\(fontName)\", -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif"
        }
    }
}

enum FontRole {
    case headline
    case subtitle
    case body
    case button
    case caption
}
