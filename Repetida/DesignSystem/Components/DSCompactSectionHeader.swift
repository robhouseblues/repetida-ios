import SwiftUI

struct DSCompactSectionHeader: View {
    let title: String

    var body: some View {
        DSSectionHeader(title: title, compact: true)
    }
}
