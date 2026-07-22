import SwiftUI

struct AtmosphericCardBackground: View {
    var cornerRadius: CGFloat = DSRadius.lg
    var tint: Color? = nil
    var strokeColor: Color? = nil
    var strokeLineWidth: CGFloat = 1
    var strokeDash: [CGFloat] = []
    var showScanlines: Bool = true
    var showGrain: Bool = true
    var showsShadow: Bool = true
    var glowColor: Color? = nil
    var dimOverlay: Color? = nil
    var innerGlowColor: Color? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DSColors.cardSurface)
            .overlay {
                CardAtmosphereOverlay(showScanlines: showScanlines, showGrain: showGrain)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .overlay {
                if let tint {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(tint)
                }
            }
            .overlay {
                if let dimOverlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(dimOverlay)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        borderStroke,
                        style: StrokeStyle(lineWidth: strokeLineWidth, dash: strokeDash)
                    )
            }
            .overlay {
                if let innerGlowColor {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .inset(by: 1)
                        .stroke(innerGlowColor, lineWidth: 2)
                        .blur(radius: 3)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            }
            .shadow(color: showsShadow ? DSShadow.card : .clear, radius: 8, y: 4)
            .shadow(color: glowColor ?? .clear, radius: 6, y: 0)
    }

    private var borderStroke: AnyShapeStyle {
        if let strokeColor {
            AnyShapeStyle(strokeColor)
        } else {
            AnyShapeStyle(
                LinearGradient(
                    colors: [
                        DSColors.primaryChrome.opacity(0.22),
                        DSColors.primaryDeep.opacity(0.10),
                        DSColors.secondary.opacity(0.06),
                        DSColors.primaryDeep.opacity(0.04),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct AtmosphericCardSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = DSRadius.lg
    var tint: Color? = nil
    var strokeColor: Color? = nil
    var strokeLineWidth: CGFloat = 1
    var strokeDash: [CGFloat] = []
    var showScanlines: Bool = true
    var showGrain: Bool = true
    var showsShadow: Bool = true
    var glowColor: Color? = nil
    var dimOverlay: Color? = nil
    var innerGlowColor: Color? = nil

    func body(content: Content) -> some View {
        content.background {
            AtmosphericCardBackground(
                cornerRadius: cornerRadius,
                tint: tint,
                strokeColor: strokeColor,
                strokeLineWidth: strokeLineWidth,
                strokeDash: strokeDash,
                showScanlines: showScanlines,
                showGrain: showGrain,
                showsShadow: showsShadow,
                glowColor: glowColor,
                dimOverlay: dimOverlay,
                innerGlowColor: innerGlowColor
            )
        }
    }
}

extension View {
    func atmosphericCardSurface(
        cornerRadius: CGFloat = DSRadius.lg,
        tint: Color? = nil,
        strokeColor: Color? = nil,
        strokeLineWidth: CGFloat = 1,
        strokeDash: [CGFloat] = [],
        showScanlines: Bool = true,
        showGrain: Bool = true,
        showsShadow: Bool = true,
        glowColor: Color? = nil,
        dimOverlay: Color? = nil,
        innerGlowColor: Color? = nil
    ) -> some View {
        modifier(
            AtmosphericCardSurfaceModifier(
                cornerRadius: cornerRadius,
                tint: tint,
                strokeColor: strokeColor,
                strokeLineWidth: strokeLineWidth,
                strokeDash: strokeDash,
                showScanlines: showScanlines,
                showGrain: showGrain,
                showsShadow: showsShadow,
                glowColor: glowColor,
                dimOverlay: dimOverlay,
                innerGlowColor: innerGlowColor
            )
        )
    }
}
