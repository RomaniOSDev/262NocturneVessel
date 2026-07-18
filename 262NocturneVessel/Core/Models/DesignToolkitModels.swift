import Foundation
import SwiftUI

// MARK: - Type scale & roles

enum TypeScaleKind: String, Codable, CaseIterable, Identifiable {
    case display
    case ui
    case editorial
    case code

    var id: String { rawValue }

    var title: String {
        switch self {
        case .display: return "Display"
        case .ui: return "UI"
        case .editorial: return "Editorial"
        case .code: return "Code"
        }
    }

    var detail: String {
        switch self {
        case .display: return "Bold marketing hierarchy with strong headlines."
        case .ui: return "Balanced product UI scale for screens and forms."
        case .editorial: return "Reading-first rhythm for long-form layouts."
        case .code: return "Technical pairing with monospace body clarity."
        }
    }
}

struct TypeRoleSizes: Codable, Equatable, Hashable {
    var h1: CGFloat
    var h2: CGFloat
    var body: CGFloat
    var button: CGFloat
    var caption: CGFloat

    static func sizes(for kind: TypeScaleKind) -> TypeRoleSizes {
        switch kind {
        case .display:
            return TypeRoleSizes(h1: 36, h2: 24, body: 16, button: 16, caption: 12)
        case .ui:
            return TypeRoleSizes(h1: 28, h2: 20, body: 15, button: 15, caption: 12)
        case .editorial:
            return TypeRoleSizes(h1: 32, h2: 22, body: 17, button: 14, caption: 13)
        case .code:
            return TypeRoleSizes(h1: 26, h2: 18, body: 14, button: 14, caption: 11)
        }
    }
}

struct TypeScaleAssignment: Codable, Equatable, Hashable {
    var kind: TypeScaleKind
    var h1Font: String
    var h2Font: String
    var bodyFont: String
    var buttonFont: String
    var captionFont: String
    var sizes: TypeRoleSizes

    static func make(kind: TypeScaleKind, headline: String, body: String) -> TypeScaleAssignment {
        let sizes = TypeRoleSizes.sizes(for: kind)
        switch kind {
        case .display:
            return TypeScaleAssignment(
                kind: kind,
                h1Font: headline,
                h2Font: headline,
                bodyFont: body,
                buttonFont: headline,
                captionFont: body,
                sizes: sizes
            )
        case .ui:
            return TypeScaleAssignment(
                kind: kind,
                h1Font: headline,
                h2Font: headline,
                bodyFont: body,
                buttonFont: headline,
                captionFont: body,
                sizes: sizes
            )
        case .editorial:
            return TypeScaleAssignment(
                kind: kind,
                h1Font: headline,
                h2Font: body,
                bodyFont: body,
                buttonFont: headline,
                captionFont: body,
                sizes: sizes
            )
        case .code:
            let mono = AvailableFonts.catalog.first(where: { $0.category == "monospace" })?.name ?? "Menlo"
            return TypeScaleAssignment(
                kind: kind,
                h1Font: headline,
                h2Font: headline,
                bodyFont: mono,
                buttonFont: headline,
                captionFont: mono,
                sizes: sizes
            )
        }
    }
}

struct PreviewCanvasContent: Codable, Equatable, Hashable {
    var headline: String
    var subtitle: String
    var paragraph: String
    var buttonTitle: String
    var caption: String

    static let `default` = PreviewCanvasContent(
        headline: "Design the quiet details",
        subtitle: "A clear secondary line sets hierarchy",
        paragraph: "Body text should stay readable across devices. Keep line length comfortable and contrast strong enough for extended reading without fatigue.",
        buttonTitle: "Start layout",
        caption: "Caption · supporting meta"
    )
}

// MARK: - Projects

enum ProjectStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case approved

    var id: String { rawValue }

    var title: String {
        switch self {
        case .draft: return "Draft"
        case .approved: return "Approved"
        }
    }
}

struct DesignProject: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var notes: String
    var status: ProjectStatus
    var pairIDs: [String]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        notes: String = "",
        status: ProjectStatus = .draft,
        pairIDs: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.status = status
        self.pairIDs = pairIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Checklist

struct ChecklistItemDefinition: Identifiable {
    let id: String
    let title: String
    let detail: String
}

enum TypographyChecklistCatalog {
    static let items: [ChecklistItemDefinition] = [
        ChecklistItemDefinition(
            id: "hierarchy",
            title: "Clear hierarchy",
            detail: "H1, H2, and body sizes are distinct and intentional."
        ),
        ChecklistItemDefinition(
            id: "line_length",
            title: "Comfortable line length",
            detail: "Body copy stays roughly 45–75 characters per line."
        ),
        ChecklistItemDefinition(
            id: "contrast",
            title: "Headline vs body contrast",
            detail: "Weight and size create readable emphasis without shouting."
        ),
        ChecklistItemDefinition(
            id: "fallbacks",
            title: "Fallback fonts noted",
            detail: "Export includes sensible CSS fallbacks for each role."
        ),
        ChecklistItemDefinition(
            id: "roles",
            title: "Roles assigned",
            detail: "Display, UI, Editorial, or Code scale matches the project brief."
        ),
        ChecklistItemDefinition(
            id: "caption_button",
            title: "Caption & button checked",
            detail: "Small text and CTA remain legible at target sizes."
        ),
        ChecklistItemDefinition(
            id: "side_by_side",
            title: "Compared alternatives",
            detail: "At least one side-by-side review was done before approval."
        ),
        ChecklistItemDefinition(
            id: "export_ready",
            title: "Export package ready",
            detail: "Markdown/CSS snippet or visual preview shared with the team."
        )
    ]
}

struct PairChecklistState: Codable, Equatable {
    var pairID: String
    var checkedIDs: [String]

    var checkedSet: Set<String> {
        get { Set(checkedIDs) }
        set { checkedIDs = Array(newValue).sorted() }
    }
}

// MARK: - Mood

enum MoodTag: String, CaseIterable, Identifiable {
    case modern
    case elegant
    case playful
    case technical

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var symbolName: String {
        switch self {
        case .modern: return "cube"
        case .elegant: return "sparkles"
        case .playful: return "face.smiling"
        case .technical: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

struct MoodSuggestion: Identifiable {
    let id: String
    let font1: String
    let font2: String
    let reason: String
    let mood: MoodTag
}

// MARK: - Readability

struct ReadabilityIssue: Identifiable, Equatable {
    let id: String
    let severity: Severity
    let message: String

    enum Severity: String {
        case info
        case warning
        case good
    }
}

struct ReadabilityReport: Equatable {
    var score: Int
    var issues: [ReadabilityIssue]
}
