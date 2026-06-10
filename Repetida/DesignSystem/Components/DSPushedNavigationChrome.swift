import SwiftUI

extension View {
    /// Navigation bar chrome for pushed screens (system back button, hidden bar background).
    /// Tab-root screens keep `.toolbar(.hidden, for: .navigationBar)` instead.
    func pushedNavigationChrome() -> some View {
        navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}
