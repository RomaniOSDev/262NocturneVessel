import SwiftUI
import UIKit

struct LayoutCanvasView: View {
    @Binding var content: PreviewCanvasContent
    let scale: TypeScaleAssignment
    var isEditable: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("LAYOUT CANVAS")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
                Spacer()
                StatusChip(title: scale.kind.title, emphasized: true)
            }
            .padding(.bottom, 12)

            canvasField(
                label: "H1",
                text: $content.headline,
                fontName: scale.h1Font,
                size: scale.sizes.h1,
                weight: .bold,
                placeholder: "Headline"
            )

            divider

            canvasField(
                label: "H2",
                text: $content.subtitle,
                fontName: scale.h2Font,
                size: scale.sizes.h2,
                weight: .semibold,
                placeholder: "Subtitle"
            )

            divider

            canvasField(
                label: "Body",
                text: $content.paragraph,
                fontName: scale.bodyFont,
                size: scale.sizes.body,
                weight: .regular,
                placeholder: "Paragraph",
                axis: .vertical
            )

            divider

            HStack(alignment: .center, spacing: 12) {
                Text("BTN")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
                    .frame(width: 36, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text(content.buttonTitle.isEmpty ? "Button" : content.buttonTitle)
                        .font(.system(size: scale.sizes.button, weight: .semibold, design: AvailableFonts.design(for: scale.buttonFont)))
                        .foregroundStyle(Color("AppBackground"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .background(Color("AppPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if isEditable {
                        TextField("Button label", text: $content.buttonTitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .padding(8)
                            .background(Color("AppBackground").opacity(0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }

            divider

            canvasField(
                label: "Cap",
                text: $content.caption,
                fontName: scale.captionFont,
                size: scale.sizes.caption,
                weight: .medium,
                placeholder: "Caption"
            )
        }
        .surfaceCard()
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("AppPrimary").opacity(0.12))
            .frame(height: 1)
            .padding(.vertical, 12)
    }

    @ViewBuilder
    private func canvasField(
        label: String,
        text: Binding<String>,
        fontName: String,
        size: CGFloat,
        weight: Font.Weight,
        placeholder: String,
        axis: Axis = .horizontal
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 36, alignment: .leading)
                .padding(.top, 4)

            Group {
                if isEditable {
                    TextField(placeholder, text: text, axis: axis)
                        .font(.system(size: size, weight: weight, design: AvailableFonts.design(for: fontName)))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(axis == .vertical ? 2...6 : 1...2)
                } else {
                    Text(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                        .font(.system(size: size, weight: weight, design: AvailableFonts.design(for: fontName)))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ReadabilityScoreCard: View {
    let report: ReadabilityReport

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Readability")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Heuristic score for hierarchy and pairing")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                ScoreRing(score: report.score, size: 52)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("AppBackground").opacity(0.45))
                    Capsule()
                        .fill(scoreColor)
                        .frame(width: geo.size.width * CGFloat(report.score) / 100)
                }
            }
            .frame(height: 8)

            ForEach(report.issues) { issue in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: icon(for: issue.severity))
                        .foregroundStyle(color(for: issue.severity))
                        .frame(width: 20)
                    Text(issue.message)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(Color("AppBackground").opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .surfaceCard()
    }

    private var scoreColor: Color {
        if report.score >= 80 { return Color("AppPrimary") }
        if report.score >= 60 { return Color("AppAccent") }
        return Color.orange
    }

    private func icon(for severity: ReadabilityIssue.Severity) -> String {
        switch severity {
        case .good: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    private func color(for severity: ReadabilityIssue.Severity) -> Color {
        switch severity {
        case .good: return Color("AppPrimary")
        case .info: return Color("AppAccent")
        case .warning: return Color.orange
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]
    var onComplete: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            onComplete?()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
