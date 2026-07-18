import Foundation

enum ReadabilityAnalyzer {
    static func analyze(pair: FontPair) -> ReadabilityReport {
        var issues: [ReadabilityIssue] = []
        var score = 100

        let cat1 = AvailableFonts.category(for: pair.font1)
        let cat2 = AvailableFonts.category(for: pair.font2)
        let scale = pair.typeScale
        let sizeGap = scale.sizes.h1 - scale.sizes.body

        if cat1 == "display" && cat2 == "display" {
            score -= 28
            issues.append(
                ReadabilityIssue(
                    id: "both_display",
                    severity: .warning,
                    message: "Both fonts are display styles — weak for long body text."
                )
            )
        }

        if cat1 == "serif" && cat2 == "serif" {
            score -= 12
            issues.append(
                ReadabilityIssue(
                    id: "serif_serif",
                    severity: .warning,
                    message: "Serif + serif without a contrasting accent can feel flat."
                )
            )
        }

        if cat1 == "monospace" && cat2 == "monospace" {
            score -= 10
            issues.append(
                ReadabilityIssue(
                    id: "mono_mono",
                    severity: .info,
                    message: "Double monospace works for code UIs, less for marketing pages."
                )
            )
        }

        if pair.font1 == pair.font2 {
            score -= 35
            issues.append(
                ReadabilityIssue(
                    id: "same_font",
                    severity: .warning,
                    message: "Headline and body use the same face — contrast is missing."
                )
            )
        }

        if sizeGap < 8 {
            score -= 18
            issues.append(
                ReadabilityIssue(
                    id: "size_gap",
                    severity: .warning,
                    message: "Headline vs body size gap is tight (\(Int(sizeGap))pt). Aim for 8pt+."
                )
            )
        } else if sizeGap >= 12 {
            issues.append(
                ReadabilityIssue(
                    id: "size_gap_good",
                    severity: .good,
                    message: "Strong size contrast between headline (\(Int(scale.sizes.h1))pt) and body (\(Int(scale.sizes.body))pt)."
                )
            )
        }

        if scale.sizes.body < 14 {
            score -= 14
            issues.append(
                ReadabilityIssue(
                    id: "body_small",
                    severity: .warning,
                    message: "Body size under 14pt may hurt readability on smaller phones."
                )
            )
        }

        if scale.sizes.caption < 11 {
            score -= 8
            issues.append(
                ReadabilityIssue(
                    id: "caption_small",
                    severity: .info,
                    message: "Caption size is very small — verify legibility on device."
                )
            )
        }

        if cat1 == "sans-serif" && cat2 == "serif" {
            issues.append(
                ReadabilityIssue(
                    id: "classic_pair",
                    severity: .good,
                    message: "Classic sans headline + serif body pairing supports clear hierarchy."
                )
            )
            score = min(100, score + 4)
        }

        if cat1 == "serif" && cat2 == "sans-serif" {
            issues.append(
                ReadabilityIssue(
                    id: "editorial_pair",
                    severity: .good,
                    message: "Serif headline with sans body suits editorial and brand stories."
                )
            )
            score = min(100, score + 3)
        }

        if pair.scaleKind == .code && cat2 != "monospace" && AvailableFonts.category(for: scale.bodyFont) != "monospace" {
            score -= 10
            issues.append(
                ReadabilityIssue(
                    id: "code_body",
                    severity: .info,
                    message: "Code scale usually benefits from a monospace body role."
                )
            )
        }

        let paragraph = pair.canvas.paragraph
        let avgLineGuess = Double(paragraph.count) / 3.0
        if avgLineGuess > 90 {
            score -= 6
            issues.append(
                ReadabilityIssue(
                    id: "line_length",
                    severity: .info,
                    message: "Paragraph copy looks long — check line length in the canvas preview."
                )
            )
        }

        if issues.filter({ $0.severity == .warning }).isEmpty && issues.contains(where: { $0.severity == .good }) {
            score = min(100, score + 2)
        }

        score = max(0, min(100, score))
        if issues.isEmpty {
            issues.append(
                ReadabilityIssue(
                    id: "balanced",
                    severity: .good,
                    message: "Pair looks balanced for size, category, and role contrast."
                )
            )
        }

        return ReadabilityReport(score: score, issues: issues)
    }
}

enum MoodMatcher {
    static func suggestions(for moods: Set<MoodTag>, limit: Int = 5) -> [MoodSuggestion] {
        guard !moods.isEmpty else { return [] }

        var results: [MoodSuggestion] = []

        let recipes: [(MoodTag, String, String, String)] = [
            (.modern, "SF Pro", "New York", "Clean sans headline with serif body keeps modern product UI readable."),
            (.modern, "Helvetica Neue", "Georgia", "Neutral UI face paired with classic reading serif."),
            (.modern, "Avenir Next", "Palatino", "Geometric sans energy with soft editorial body."),
            (.elegant, "Didot", "Optima", "High-contrast display Didot with refined Optima support."),
            (.elegant, "Baskerville", "Gill Sans", "Literary serif headline tempered by humanist sans body."),
            (.elegant, "New York", "Avenir Next", "Apple serif elegance with contemporary sans body."),
            (.playful, "SF Pro Rounded", "Verdana", "Rounded headline softens the tone; Verdana keeps body friendly."),
            (.playful, "Futura", "Trebuchet MS", "Geometric Futura plus approachable Trebuchet for light campaigns."),
            (.playful, "Gill Sans", "SF Pro Rounded", "Humanist sans with rounded companion for informal UI."),
            (.technical, "SF Pro", "Menlo", "Product sans with monospace body for docs and dashboards."),
            (.technical, "Helvetica Neue", "Courier New", "Industrial UI pairing suited to specs and tooling."),
            (.technical, "Avenir Next", "Menlo", "Modern geometric UI with precise monospace reading.")
        ]

        for recipe in recipes where moods.contains(recipe.0) {
            results.append(
                MoodSuggestion(
                    id: "\(recipe.0.rawValue)-\(recipe.1)-\(recipe.2)",
                    font1: recipe.1,
                    font2: recipe.2,
                    reason: recipe.3,
                    mood: recipe.0
                )
            )
        }

        return Array(results.prefix(limit))
    }
}

enum PairExportBuilder {
    static func markdown(for pair: FontPair) -> String {
        let scale = pair.typeScale
        return """
        # \(pair.name)

        \(pair.pairDescription.isEmpty ? "Font pairing export" : pair.pairDescription)

        ## Roles
        - H1: \(scale.h1Font) · \(Int(scale.sizes.h1))pt
        - H2: \(scale.h2Font) · \(Int(scale.sizes.h2))pt
        - Body: \(scale.bodyFont) · \(Int(scale.sizes.body))pt
        - Button: \(scale.buttonFont) · \(Int(scale.sizes.button))pt
        - Caption: \(scale.captionFont) · \(Int(scale.sizes.caption))pt

        ## Sample
        **\(pair.canvas.headline)**
        *\(pair.canvas.subtitle)*

        \(pair.canvas.paragraph)

        [\(pair.canvas.buttonTitle)]
        \(pair.canvas.caption)

        ## Scale
        Preset: \(pair.scaleKind.title)
        """
    }

    static func css(for pair: FontPair) -> String {
        let scale = pair.typeScale
        return """
        :root {
          --font-h1: \(AvailableFonts.cssStack(for: scale.h1Font));
          --font-h2: \(AvailableFonts.cssStack(for: scale.h2Font));
          --font-body: \(AvailableFonts.cssStack(for: scale.bodyFont));
          --font-button: \(AvailableFonts.cssStack(for: scale.buttonFont));
          --font-caption: \(AvailableFonts.cssStack(for: scale.captionFont));
          --size-h1: \(Int(scale.sizes.h1))px;
          --size-h2: \(Int(scale.sizes.h2))px;
          --size-body: \(Int(scale.sizes.body))px;
          --size-button: \(Int(scale.sizes.button))px;
          --size-caption: \(Int(scale.sizes.caption))px;
        }

        .h1 { font-family: var(--font-h1); font-size: var(--size-h1); font-weight: 700; }
        .h2 { font-family: var(--font-h2); font-size: var(--size-h2); font-weight: 600; }
        .body { font-family: var(--font-body); font-size: var(--size-body); font-weight: 400; }
        .button { font-family: var(--font-button); font-size: var(--size-button); font-weight: 600; }
        .caption { font-family: var(--font-caption); font-size: var(--size-caption); font-weight: 500; }
        """
    }

    static func figmaNotionSnippet(for pair: FontPair) -> String {
        let scale = pair.typeScale
        return """
        Pair: \(pair.name)
        Scale: \(pair.scaleKind.title)

        H1 — \(scale.h1Font) / \(Int(scale.sizes.h1))
        H2 — \(scale.h2Font) / \(Int(scale.sizes.h2))
        Body — \(scale.bodyFont) / \(Int(scale.sizes.body))
        Button — \(scale.buttonFont) / \(Int(scale.sizes.button))
        Caption — \(scale.captionFont) / \(Int(scale.sizes.caption))

        Copy:
        \(pair.canvas.headline)
        \(pair.canvas.subtitle)
        \(pair.canvas.paragraph)
        """
    }
}
