import SwiftUI
import UIKit
import UniformTypeIdentifiers

enum ExchangeShareTemplate {
    case story
    case square

    /// Logical canvas at @3x → 1080×1920 story, 1080×1080 square.
    var canvasSize: CGSize {
        switch self {
        case .story: CGSize(width: 360, height: 640)
        case .square: CGSize(width: 360, height: 360)
        }
    }

    var columnCount: Int {
        switch self {
        case .story: 4
        case .square: 4
        }
    }

    var maxVisibleStickers: Int {
        switch self {
        case .story: columnCount * 15
        case .square: 24
        }
    }

    var gridSpacing: CGFloat {
        switch self {
        case .story: 1
        case .square: 3
        }
    }
}

struct ExchangeShareStickerEntry: Identifiable {
    let sticker: NormalizedSticker
    let team: Team?
    let duplicateCount: Int

    var id: String { sticker.code }
}

struct ExchangeSharePayload {
    let totalCopies: Int
    let stickers: [ExchangeShareStickerEntry]

    func visibleStickers(for template: ExchangeShareTemplate) -> [ExchangeShareStickerEntry] {
        ExchangeShareSelectionHelper.diverseSubset(stickers, limit: template.maxVisibleStickers)
    }

    func hiddenCopyCount(for template: ExchangeShareTemplate) -> Int {
        let shown = visibleStickers(for: template)
            .reduce(0) { $0 + $1.duplicateCount }
        return max(0, totalCopies - shown)
    }
}

enum ExchangeShareSortHelper {
    static func sortedByAlbumOrder(_ items: [ExchangeStickerItem]) -> [ExchangeStickerItem] {
        items.sorted { NormalizedSticker.compareByAlbumOrder($0.sticker, $1.sticker) }
    }
}

enum ExchangeShareSelectionHelper {
    /// Picks a team-diverse subset, then returns it in album order for scanning.
    static func diverseSubset(
        _ entries: [ExchangeShareStickerEntry],
        limit: Int
    ) -> [ExchangeShareStickerEntry] {
        guard entries.count > limit else { return entries }

        var buckets: [(teamKey: String, entries: [ExchangeShareStickerEntry])] = []
        var bucketIndex: [String: Int] = [:]

        for entry in entries {
            let key = entry.team?.id ?? entry.sticker.teamId
            if let index = bucketIndex[key] {
                buckets[index].entries.append(entry)
            } else {
                bucketIndex[key] = buckets.count
                buckets.append((key, [entry]))
            }
        }

        var picked: [ExchangeShareStickerEntry] = []
        var pointers = Array(repeating: 0, count: buckets.count)

        while picked.count < limit {
            var addedAny = false
            for index in buckets.indices {
                guard picked.count < limit else { break }
                guard pointers[index] < buckets[index].entries.count else { continue }
                picked.append(buckets[index].entries[pointers[index]])
                pointers[index] += 1
                addedAny = true
            }
            if !addedAny { break }
        }

        return picked.sorted { NormalizedSticker.compareByAlbumOrder($0.sticker, $1.sticker) }
    }
}

struct ShareableImage: Transferable {
    let image: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.image.pngData() ?? Data()
        }
    }
}

struct ExchangeShareCardView: View {
    let payload: ExchangeSharePayload
    let template: ExchangeShareTemplate

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: template.gridSpacing),
            count: template.columnCount
        )
    }

    private var visibleStickers: [ExchangeShareStickerEntry] {
        payload.visibleStickers(for: template)
    }

    var body: some View {
        Group {
            switch template {
            case .story:
                storyLayout
            case .square:
                squareLayout
            }
        }
        .frame(width: template.canvasSize.width, height: template.canvasSize.height)
        .background(ShareCardAtmosphere())
    }
}

// MARK: - Story (9:16 inventory-first)

private extension ExchangeShareCardView {
    var storyLayout: some View {
        VStack(alignment: .leading, spacing: 3) {
            tradingHeader(compact: false)

            LazyVGrid(columns: columns, spacing: template.gridSpacing) {
                ForEach(visibleStickers) { entry in
                    compactStickerTile(entry: entry, codeSize: 7, nameSize: 6)
                }
            }

            if payload.hiddenCopyCount(for: template) > 0 {
                Text(L10n.exchangeShareOverflowCopies(payload.hiddenCopyCount(for: template)))
                    .font(DSTypography.caption(9))
                    .foregroundStyle(DSColors.textMuted)
            }

            shareFooter(compact: false)
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.xs)
    }
}

// MARK: - Square (1:1 maximum density)

private extension ExchangeShareCardView {
    var squareLayout: some View {
        VStack(alignment: .leading, spacing: 3) {
            tradingHeader(compact: true)

            LazyVGrid(columns: columns, spacing: template.gridSpacing) {
                ForEach(visibleStickers) { entry in
                    compactStickerTile(entry: entry, codeSize: 7, nameSize: 6)
                }
            }

            if payload.hiddenCopyCount(for: template) > 0 {
                Text(L10n.exchangeShareOverflowCopies(payload.hiddenCopyCount(for: template)))
                    .font(DSTypography.caption(8))
                    .foregroundStyle(DSColors.textMuted)
            }

            shareFooter(compact: true)
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.sm)
    }
}

// MARK: - Shared pieces

private extension ExchangeShareCardView {
    func tradingHeader(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(L10n.exchangeShareTradingHeadlineLine1(payload.totalCopies))
                .font(DSTypography.display(compact ? 11 : 13))
                .foregroundStyle(DSColors.textPrimary)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)

            Text(L10n.exchangeShareTradingHeadlineLine2)
                .font(DSTypography.display(compact ? 10 : 12))
                .foregroundStyle(DSColors.goldFoil)
                .textCase(.uppercase)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func compactStickerTile(
        entry: ExchangeShareStickerEntry,
        codeSize: CGFloat,
        nameSize: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 2) {
                if let flag = entry.team?.flagEmoji {
                    Text(flag)
                        .font(.system(size: codeSize))
                }
                Text(entry.sticker.code)
                    .font(DSTypography.stickerCode(codeSize))
                    .foregroundStyle(DSColors.goldFoil)
                    .lineLimit(1)
                if entry.sticker.isShiny {
                    Image(systemName: "sparkles")
                        .font(.system(size: codeSize - 1))
                        .foregroundStyle(DSColors.goldFoil)
                }
                if entry.duplicateCount > 1 {
                    Text(L10n.exchangeShareQuantity(entry.duplicateCount))
                        .font(DSTypography.stickerCode(codeSize - 1))
                        .foregroundStyle(DSColors.duplicate)
                }
            }

            Text(entry.sticker.name)
                .font(DSTypography.caption(nameSize))
                .foregroundStyle(DSColors.textMuted)
                .lineLimit(1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, compact ? 2 : 2)
        .frame(maxWidth: .infinity, minHeight: compact ? 28 : 26, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(DSColors.surface.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(DSColors.primaryChrome.opacity(0.28), lineWidth: 0.75)
                )
        )
    }

    func shareFooter(compact: Bool) -> some View {
        VStack(alignment: .trailing, spacing: compact ? 3 : 4) {
            Text(L10n.exchangeShareCTA)
                .font(DSTypography.caption(compact ? 9 : 10))
                .foregroundStyle(DSColors.textPrimary.opacity(0.85))
                .textCase(.uppercase)

            HStack(spacing: 4) {
                Text(L10n.exchangeShareAttribution)
                    .font(DSTypography.caption(compact ? 8 : 9))
                    .foregroundStyle(DSColors.textMuted.opacity(0.75))

                Image("AppMark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: compact ? 12 : 14, height: compact ? 12 : 14)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 1)
    }

    var compact: Bool {
        template == .square
    }
}

// MARK: - Football atmosphere background

private struct ShareCardAtmosphere: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DSColors.pitchDeep,
                    Color(red: 6 / 255, green: 28 / 255, blue: 14 / 255),
                    DSColors.pitchDeep,
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    DSColors.primaryBright.opacity(0.14),
                    Color.clear,
                ],
                center: .top,
                startRadius: 0,
                endRadius: 260
            )

            GeometryReader { proxy in
                let lineSpacing = proxy.size.height / 10
                Canvas { context, size in
                    for index in 1..<10 {
                        let y = lineSpacing * CGFloat(index)
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(
                            path,
                            with: .color(DSColors.primaryChrome.opacity(0.06)),
                            lineWidth: 1
                        )
                    }
                }
            }
        }
    }
}

enum ExchangeShareRenderer {
    @MainActor
    static func render(
        payload: ExchangeSharePayload,
        template: ExchangeShareTemplate
    ) -> UIImage? {
        let view = ExchangeShareCardView(payload: payload, template: template)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        return renderer.uiImage
    }
}

struct ExchangeShareSheet: View {
    let payload: ExchangeSharePayload
    let whatsAppText: String
    @State private var copiedTextList = false
    @State private var showWhatsAppPreview = false
    @State private var selectedDetent: PresentationDetent = .height(360)
    @State private var storyImage: UIImage?
    @State private var squareImage: UIImage?
    @State private var isRenderingShareImages = true

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader

            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    summarySection

                    Button {
                        UIPasteboard.general.string = whatsAppText
                        copiedTextList = true
                        HapticFeedback.success()
                    } label: {
                        HStack {
                            Image(systemName: copiedTextList ? "checkmark.circle.fill" : "doc.on.doc")
                            Text(copiedTextList ? L10n.exchangeShareCopied : L10n.exchangeCopyTextList)
                            Spacer()
                        }
                        .font(DSTypography.body())
                        .foregroundStyle(DSColors.textPrimary)
                        .padding(DSSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                                .fill(DSColors.primaryMuted.opacity(0.35))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                                        .strokeBorder(DSColors.primaryChrome, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    if isRenderingShareImages && storyImage == nil && squareImage == nil {
                        ProgressView()
                            .tint(DSColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.md)
                    }

                    if let image = storyImage {
                        ShareLink(
                            item: ShareableImage(image: image),
                            preview: SharePreview(L10n.exchangeShareStory, image: Image(uiImage: image))
                        ) {
                            shareButtonLabel(L10n.exchangeShareStory, icon: "rectangle.portrait")
                        }
                    }

                    if let image = squareImage {
                        ShareLink(
                            item: ShareableImage(image: image),
                            preview: SharePreview(L10n.exchangeShareSquare, image: Image(uiImage: image))
                        ) {
                            shareButtonLabel(L10n.exchangeShareSquare, icon: "square")
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.bottom, DSSpacing.lg)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(DSColors.screenBackground)
        .presentationDetents(showWhatsAppPreview ? [.height(360), .medium] : [.height(360)], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.screenBackground)
        .onChange(of: showWhatsAppPreview) { _, expanded in
            selectedDetent = expanded ? .medium : .height(360)
        }
        .task {
            let story = ExchangeShareRenderer.render(payload: payload, template: .story)
            let square = ExchangeShareRenderer.render(payload: payload, template: .square)
            storyImage = story
            squareImage = square
            isRenderingShareImages = false
        }
    }

    private var sheetHeader: some View {
        Text(L10n.exchangeShare.uppercased())
            .font(DSTypography.display(18))
            .fontWeight(.semibold)
            .foregroundStyle(DSColors.textPrimary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DSSpacing.lg)
            .padding(.top, DSSpacing.xxl)
            .padding(.bottom, DSSpacing.xl)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(L10n.exchangeShareSheetHeadline(payload.totalCopies))
                .font(DSTypography.body())
                .foregroundStyle(DSColors.textPrimary)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showWhatsAppPreview.toggle()
                }
            } label: {
                HStack {
                    Text(L10n.exchangeShareShowListPreview)
                    Spacer()
                    Image(systemName: showWhatsAppPreview ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                }
                .font(DSTypography.caption())
                .foregroundStyle(DSColors.textMuted)
                .padding(.top, DSSpacing.xs)
            }
            .buttonStyle(.plain)

            if showWhatsAppPreview {
                Text(whatsAppText)
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DSSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                            .fill(DSColors.surface)
                    )
            }
        }
    }

    private func shareButtonLabel(_ title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            Image(systemName: "square.and.arrow.up")
        }
        .font(DSTypography.body())
        .foregroundStyle(DSColors.textPrimary)
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .fill(DSColors.surface)
        )
    }
}
