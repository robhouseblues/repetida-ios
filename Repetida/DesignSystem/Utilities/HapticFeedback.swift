import UIKit

enum HapticFeedback {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let successNotification = UINotificationFeedbackGenerator()

    static func light() {
        lightImpact.prepare()
        lightImpact.impactOccurred()
    }

    static func success() {
        successNotification.prepare()
        successNotification.notificationOccurred(.success)
    }
}
