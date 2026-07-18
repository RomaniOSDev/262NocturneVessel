import SwiftUI
import UIKit

struct ExportPanelView: View {
    let pair: FontPair
    let onShare: ([Any]) -> Void

    @State private var selectedFormat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Export for handoff")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            Picker("Format", selection: $selectedFormat) {
                Text("Snippet").tag(0)
                Text("Markdown").tag(1)
                Text("CSS").tag(2)
                Text("Image").tag(3)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedFormat) { _ in
                FeedbackHelper.lightTap()
            }

            ScrollView {
                Text(previewText)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .frame(maxHeight: 220)

            exportCanvasPreview
                .allowsHitTesting(false)

            Button {
                FeedbackHelper.mediumTap()
                shareCurrent()
            } label: {
                Text(selectedFormat == 3 ? "Share PNG Preview" : "Share Text Export")
                    .frame(maxWidth: .infinity)
                    .bottomButtonStyle()
            }
        }
        .padding(16)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var previewText: String {
        switch selectedFormat {
        case 1: return PairExportBuilder.markdown(for: pair)
        case 2: return PairExportBuilder.css(for: pair)
        case 3: return "Renders a PNG of the live layout canvas for Slack, Notion, or email."
        default: return PairExportBuilder.figmaNotionSnippet(for: pair)
        }
    }

    private var exportCanvasPreview: some View {
        LayoutCanvasView(
            content: .constant(pair.canvas),
            scale: pair.typeScale,
            isEditable: false
        )
        .id(pair.id)
    }

    private func shareCurrent() {
        switch selectedFormat {
        case 1:
            onShare([PairExportBuilder.markdown(for: pair)])
        case 2:
            onShare([PairExportBuilder.css(for: pair)])
        case 3:
            Task { @MainActor in
                if let image = renderPreviewImage() {
                    onShare([image])
                } else {
                    onShare([PairExportBuilder.figmaNotionSnippet(for: pair)])
                }
            }
        default:
            onShare([PairExportBuilder.figmaNotionSnippet(for: pair)])
        }
    }

    @MainActor
    private func renderPreviewImage() -> UIImage? {
        let view = LayoutCanvasView(
            content: .constant(pair.canvas),
            scale: pair.typeScale,
            isEditable: false
        )
        .frame(width: 320)
        .padding(8)
        .background(Color("AppBackground"))

        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
