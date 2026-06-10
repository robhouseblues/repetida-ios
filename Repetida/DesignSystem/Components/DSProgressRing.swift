import SwiftUI

struct DSProgressRing: View {
    static let defaultSize: CGFloat = 120
    static let defaultLineWidth: CGFloat = 10
    static let defaultPercentageFontSize: CGFloat = 22
    static let defaultLabelFontSize: CGFloat = 12

    static func lineWidth(for size: CGFloat) -> CGFloat {
        size * (defaultLineWidth / defaultSize)
    }

    let progress: Double
    let label: String
    var size: CGFloat = defaultSize
    var lineWidth: CGFloat = defaultLineWidth
    var progressColor: Color = DSColors.primary
    var useGradient: Bool = false

    private var scale: CGFloat { size / Self.defaultSize }

    private var percentageFontSize: CGFloat {
        max(10, Self.defaultPercentageFontSize * scale)
    }

    private var labelFontSize: CGFloat {
        max(9, Self.defaultLabelFontSize * scale)
    }

    private var progressStroke: AnyShapeStyle {
        if useGradient {
            AnyShapeStyle(DSColors.progressGradient)
        } else {
            AnyShapeStyle(progressColor)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(DSColors.missing, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressStroke,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            VStack(spacing: DSSpacing.xs * scale) {
                Text("\(Int(progress * 100))%")
                    .font(DSTypography.display(percentageFontSize))
                    .foregroundStyle(DSColors.textPrimary)
                Text(label)
                    .font(DSTypography.caption(labelFontSize))
                    .foregroundStyle(DSColors.textMuted)
            }
        }
        .frame(width: size, height: size)
    }
}
