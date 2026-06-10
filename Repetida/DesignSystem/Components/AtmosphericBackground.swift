import SwiftUI

struct ScreenBackground: View {
    var body: some View {
        DSColors.screenBackground
            .ignoresSafeArea()
    }
}

struct AtmosphericBackground: View {
    var body: some View {
        ZStack {
            DSColors.stadiumGradient
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    DSColors.primaryDeep.opacity(0.10),
                    Color.clear,
                ],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 380
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    DSColors.secondary.opacity(0.025),
                    Color.clear,
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()
        }
    }
}
