import SwiftUI

enum ExchangeDragZone: Hashable {
    case add
    case remove

    static func zone(containing point: CGPoint, in frames: [ExchangeDragZone: CGRect]) -> ExchangeDragZone? {
        frames.first { $0.value.contains(point) }?.key
    }
}

struct ExchangeDragSession: Equatable {
    let stickerCode: String
    let originFrame: CGRect
    var translation: CGSize = .zero
}

private struct ExchangeDragDockFrameKey: PreferenceKey {
    static var defaultValue: [ExchangeDragZone: CGRect] = [:]

    static func reduce(value: inout [ExchangeDragZone: CGRect], nextValue: () -> [ExchangeDragZone: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct ExchangeTileFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct ExchangeDragDock: View {
    let hoveredZone: ExchangeDragZone?

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            dockZone(
                zone: .remove,
                title: L10n.exchangeDockRemove,
                icon: "minus.circle.fill",
                accent: Color.red.opacity(0.9),
                isHovered: hoveredZone == .remove
            )

            dockZone(
                zone: .add,
                title: L10n.exchangeDockMore,
                icon: "plus.circle.fill",
                accent: DSColors.primary,
                isHovered: hoveredZone == .add
            )
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .fill(DSColors.surface.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                        .strokeBorder(DSColors.cardBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 16, y: 6)
        )
    }

    private func dockZone(
        zone: ExchangeDragZone,
        title: String,
        icon: String,
        accent: Color,
        isHovered: Bool
    ) -> some View {
        VStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
            Text(title)
                .font(DSTypography.body())
                .fontWeight(.semibold)
        }
        .foregroundStyle(isHovered ? DSColors.textPrimary : DSColors.textMuted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .fill(isHovered ? accent.opacity(0.35) : DSColors.pitchDeep.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                        .strokeBorder(
                            isHovered ? accent.opacity(0.9) : DSColors.cardBorder,
                            lineWidth: isHovered ? 2 : 1
                        )
                )
        )
        .scaleEffect(isHovered ? 1.04 : 1)
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ExchangeDragDockFrameKey.self,
                    value: [zone: proxy.frame(in: .global)]
                )
            }
        }
    }
}

struct ExchangeDragPreview: View {
    let item: ExchangeStickerItem
    let session: ExchangeDragSession

    var body: some View {
        DSStickerTile(
            sticker: item.sticker,
            status: item.status,
            onTap: {},
            onAddDuplicate: {},
            showsToggleOwned: false,
            isTapEnabled: false,
            showsContextMenu: false
        )
        .frame(width: session.originFrame.width, height: session.originFrame.height)
        .scaleEffect(1.05)
        .shadow(color: .black.opacity(0.4), radius: 14, y: 6)
        .position(
            x: session.originFrame.midX + session.translation.width,
            y: session.originFrame.midY + session.translation.height
        )
        .allowsHitTesting(false)
    }
}

struct ExchangeDraggableTile: View {
    let item: ExchangeStickerItem
    @Binding var dragSession: ExchangeDragSession?
    @Binding var hoveredZone: ExchangeDragZone?
    let tileFrames: [String: CGRect]
    let dockFrames: [ExchangeDragZone: CGRect]
    let onAdd: () -> Void
    let onRemove: () -> Void

    private var isDragging: Bool {
        dragSession?.stickerCode == item.sticker.code
    }

    var body: some View {
        DSStickerTile(
            sticker: item.sticker,
            status: item.status,
            onTap: {},
            onAddDuplicate: onAdd,
            showsToggleOwned: false,
            isTapEnabled: false,
            showsContextMenu: false
        )
        .opacity(isDragging ? 0.2 : 1)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ExchangeTileFrameKey.self,
                    value: [item.sticker.code: proxy.frame(in: .global)]
                )
            }
        }
        .highPriorityGesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged { value in
                guard dragSession == nil || dragSession?.stickerCode == item.sticker.code else { return }

                let originFrame = tileFrames[item.sticker.code] ?? dragSession?.originFrame ?? .zero
                guard originFrame.width > 0, originFrame.height > 0 else { return }

                if dragSession == nil {
                    HapticFeedback.light()
                }

                dragSession = ExchangeDragSession(
                    stickerCode: item.sticker.code,
                    originFrame: originFrame,
                    translation: value.translation
                )
                hoveredZone = ExchangeDragZone.zone(containing: value.location, in: dockFrames)
            }
            .onEnded { value in
                guard dragSession?.stickerCode == item.sticker.code else { return }

                if let zone = ExchangeDragZone.zone(containing: value.location, in: dockFrames) {
                    switch zone {
                    case .add:
                        onAdd()
                        HapticFeedback.success()
                    case .remove:
                        onRemove()
                        HapticFeedback.light()
                    }
                }

                withAnimation(.easeOut(duration: 0.2)) {
                    dragSession = nil
                    hoveredZone = nil
                }
            }
    }
}

extension View {
    func exchangeDragDockFrames(_ frames: Binding<[ExchangeDragZone: CGRect]>) -> some View {
        onPreferenceChange(ExchangeDragDockFrameKey.self) { frames.wrappedValue = $0 }
    }

    func exchangeTileFrames(_ frames: Binding<[String: CGRect]>) -> some View {
        onPreferenceChange(ExchangeTileFrameKey.self) { frames.wrappedValue = $0 }
    }
}
