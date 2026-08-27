import SwiftUI

#if DEBUG

@available(iOS 14.0, *)
struct DarkModeSwatchGrid: View {

    let title: String
    let entries: [SwatchEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.body16M)
                .foregroundColor(.contentPrimary)

            VStack(spacing: 6) {
                ForEach(entries) { entry in
                    SwatchRow(entry: entry)
                }
            }
        }
        .padding(16)
    }
}

@available(iOS 14.0, *)
struct SwatchEntry: Identifiable {
    let id: String
    let color: Color
    let notes: String?

    init(_ id: String, _ color: Color, notes: String? = nil) {
        self.id = id
        self.color = color
        self.notes = notes
    }
}

@available(iOS 14.0, *)
private struct SwatchRow: View {

    let entry: SwatchEntry

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(entry.color)
                .frame(width: 40, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.id)
                    .font(.body14M)
                    .foregroundColor(.contentPrimary)
                if let notes = entry.notes {
                    Text(notes)
                        .font(.body12R)
                        .foregroundColor(.contentSecondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

@available(iOS 14.0, *)
enum DarkModePalette {

    static let primary: [SwatchEntry] = [
        .init("stackBlue", .stackBlue, notes: "#011B33 — content primary today"),
        .init("navy02", .navy02, notes: "#596A7A — content secondary today"),
        .init("navy03", .navy03, notes: "#98A6AD — content tertiary today"),
        .init("navy04", .navy04, notes: "#CCD1D6 — border strong / placeholder"),
        .init("navy05", .navy05, notes: "#E6E8EB — border subtle / surface secondary")
    ]

    static let secondary: [SwatchEntry] = [
        .init("stackGreen", .stackGreen, notes: "#3BB75E — accent primary"),
        .init("green02", .green02, notes: "#1D853A — accent secondary (fails 4.5:1 dark)")
    ]

    static let error: [SwatchEntry] = [
        .init("error01", .error01, notes: "#880202 — content error (fails dark)"),
        .init("error02", .error02, notes: "#D44141 — border error")
    ]

    static let warning: [SwatchEntry] = [
        .init("warning01", .warning01, notes: "#673700 — test-mode content"),
        .init("warning02", .warning02, notes: "#FFAA22 — content warning / countdown"),
        .init("warning04", .warning04, notes: "#FFE4B8 — test-mode border"),
        .init("warning05", .warning05, notes: "#FFF6DF — test-mode surface")
    ]

    static let neutral: [SwatchEntry] = [
        .init("gray01", .gray01, notes: "#999DA1 — muted icon / track / shimmer base")
    ]

    static let semanticSurfaces: [SwatchEntry] = [
        .init("surfacePrimary", .surfacePrimary, notes: "Sheet root"),
        .init("surfaceSecondary", .surfaceSecondary, notes: "Filled inset chip"),
        .init("surfaceTertiary", .surfaceTertiary, notes: "Deepest surface (reserved)"),
        .init("surfaceInsetTranslucent", .surfaceInsetTranslucent, notes: "Capitec stepsCard"),
        .init("overlayScrim", .overlayScrim, notes: "Reserved — no current site")
    ]

    static let semanticBorders: [SwatchEntry] = [
        .init("borderPrimary", .borderPrimary, notes: "Hairline on cards"),
        .init("borderSubtle", .borderSubtle, notes: "Channel row"),
        .init("borderStrong", .borderStrong, notes: "Input / picker"),
        .init("borderError", .borderError, notes: "Field error border")
    ]

    static let semanticContent: [SwatchEntry] = [
        .init("contentPrimary", .contentPrimary, notes: "Body / heading text"),
        .init("contentSecondary", .contentSecondary, notes: "Secondary body"),
        .init("contentTertiary", .contentTertiary, notes: "Caption"),
        .init("contentPlaceholder", .contentPlaceholder, notes: "Placeholder"),
        .init("contentWarning", .contentWarning, notes: "Warning / countdown"),
        .init("contentError", .contentError, notes: "Validation message"),
        .init("contentOnAccent", .contentOnAccent, notes: "Label on green CTA"),
        .init("contentOnAccentPressed", .contentOnAccentPressed, notes: "Pressed label")
    ]

    static let semanticAccents: [SwatchEntry] = [
        .init("accentPrimary", .accentPrimary, notes: "Green CTA / focus ring"),
        .init("accentPrimaryDisabled", .accentPrimaryDisabled, notes: "CTA disabled"),
        .init("accentPrimaryPressed", .accentPrimaryPressed, notes: "CTA pressed"),
        .init("accentSecondary", .accentSecondary, notes: "Outline button text")
    ]

    static let semanticAuxiliaries: [SwatchEntry] = [
        .init("iconMuted", .iconMuted, notes: "Muted glyph"),
        .init("spinnerTint", .spinnerTint, notes: "Spinner"),
        .init("trackInactive", .trackInactive, notes: "Progress track")
    ]

    static let semanticWarningInfoTest: [SwatchEntry] = [
        .init("warningSurface", .warningSurface, notes: "Warning banner"),
        .init("infoSurface", .infoSurface, notes: "Info banner"),
        .init("toastSurface", .toastSurface, notes: "Toast pill"),
        .init("testModeContent", .testModeContent, notes: "Test-mode chip text"),
        .init("testModeSurface", .testModeSurface, notes: "Test-mode chip fill"),
        .init("testModeBorder", .testModeBorder, notes: "Test-mode chip border")
    ]

    static let semanticFixed: [SwatchEntry] = [
        .init("qrPlate", .qrPlate, notes: "QR quiet-zone — must not invert"),
        .init("shimmerBase", .shimmerBase, notes: "QR loader base"),
        .init("shimmerHighlight", .shimmerHighlight, notes: "QR loader gloss"),
        .init("pinSlotSurface", .pinSlotSurface, notes: "PIN slot fill"),
        .init("pinSlotBorder", .pinSlotBorder, notes: "PIN slot border")
    ]
}

@available(iOS 14.0, *)
struct DarkModePreviews_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            allSwatches
                .previewDisplayName("All tokens — Light")
                .preferredColorScheme(.light)

            allSwatches
                .background(Color.surfacePrimary)
                .previewDisplayName("All tokens — Dark")
                .preferredColorScheme(.dark)
        }
    }

    private static var allSwatches: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text("Semantic tokens (target layer)")
                    .font(.heading2)
                    .foregroundColor(.contentPrimary)
                    .padding(.horizontal, 16)

                DarkModeSwatchGrid(title: "Surfaces",
                                   entries: DarkModePalette.semanticSurfaces)
                DarkModeSwatchGrid(title: "Borders",
                                   entries: DarkModePalette.semanticBorders)
                DarkModeSwatchGrid(title: "Content",
                                   entries: DarkModePalette.semanticContent)
                DarkModeSwatchGrid(title: "Accents",
                                   entries: DarkModePalette.semanticAccents)
                DarkModeSwatchGrid(title: "Auxiliaries",
                                   entries: DarkModePalette.semanticAuxiliaries)
                DarkModeSwatchGrid(title: "Warning / info / test-mode / toast",
                                   entries: DarkModePalette.semanticWarningInfoTest)
                DarkModeSwatchGrid(title: "Fixed / shimmer / PIN",
                                   entries: DarkModePalette.semanticFixed)

                Divider()
                    .padding(.horizontal, 16)

                Text("Hue tokens (kept as internal primitives per Q8)")
                    .font(.heading2)
                    .foregroundColor(.contentPrimary)
                    .padding(.horizontal, 16)

                DarkModeSwatchGrid(title: "Primary",
                                   entries: DarkModePalette.primary)
                DarkModeSwatchGrid(title: "Secondary",
                                   entries: DarkModePalette.secondary)
                DarkModeSwatchGrid(title: "Error",
                                   entries: DarkModePalette.error)
                DarkModeSwatchGrid(title: "Warning",
                                   entries: DarkModePalette.warning)
                DarkModeSwatchGrid(title: "Neutral",
                                   entries: DarkModePalette.neutral)
            }
            .padding(.vertical, 16)
        }
    }
}

#endif
