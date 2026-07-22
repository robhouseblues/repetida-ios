import SwiftUI

struct GrainTexture: View {
    var opacity: Double = 0.035

    var body: some View {
        Canvas { context, size in
            // Keep grain cheap — dense per-tile fills were freezing scroll/drag.
            let density = max(1, Int(size.width * size.height * 0.008))
            for index in 0..<density {
                var generator = SeededRandomNumberGenerator(seed: UInt64(index &* 7919))
                let x = CGFloat.random(in: 0..<size.width, using: &generator)
                let y = CGFloat.random(in: 0..<size.height, using: &generator)
                let brightness = Double.random(in: 0.15...1.0, using: &generator)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(
                    Path(rect),
                    with: .color(.white.opacity(opacity * brightness))
                )
            }
        }
        .allowsHitTesting(false)
        .blendMode(.overlay)
    }
}

struct ScanlineOverlay: View {
    var opacity: Double = 0.025
    var spacing: CGFloat = 3

    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                context.fill(Path(rect), with: .color(.white.opacity(opacity)))
                y += spacing
            }
        }
        .allowsHitTesting(false)
    }
}

struct CardAtmosphereOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var showScanlines: Bool = true
    var showGrain: Bool = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DSColors.surface.opacity(0.92),
                    DSColors.surface.opacity(0.98),
                    DSColors.background.opacity(0.95),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    DSColors.primaryDeep.opacity(0.08),
                    DSColors.primaryDeep.opacity(0.02),
                    Color.clear,
                ],
                center: .top,
                startRadius: 0,
                endRadius: 220
            )

            RadialGradient(
                colors: [
                    DSColors.secondary.opacity(0.04),
                    Color.clear,
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 140
            )

            RadialGradient(
                colors: [
                    DSColors.surface.opacity(0.2),
                    Color.clear,
                ],
                center: .topLeading,
                startRadius: 8,
                endRadius: 180
            )

            RadialGradient(
                colors: [
                    Color.clear,
                    DSColors.background.opacity(0.6),
                ],
                center: .center,
                startRadius: 40,
                endRadius: 280
            )

            if !reduceMotion {
                if showGrain {
                    GrainTexture(opacity: 0.032)
                }
                if showScanlines {
                    ScanlineOverlay(opacity: 0.018, spacing: 4)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
