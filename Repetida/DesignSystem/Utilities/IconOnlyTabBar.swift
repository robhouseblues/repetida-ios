import SwiftUI
import UIKit

enum IconOnlyTabBar {
    static func icon(_ systemName: String) -> Image {
        Image(systemName: systemName)
    }

    static func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(
            red: 3 / 255,
            green: 3 / 255,
            blue: 4 / 255,
            alpha: 1
        )
        appearance.shadowColor = UIColor(
            red: 0 / 255,
            green: 122 / 255,
            blue: 50 / 255,
            alpha: 0.22
        )

        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance]
            .forEach(hideTitles)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private static func hideTitles(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        itemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 100)
        itemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 100)
    }
}
