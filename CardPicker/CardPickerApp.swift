import SwiftUI
import SwiftData

/// The main app entry point. Configures SwiftData container and NavigationStack.
@main
struct CardPickerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: CreditCard.self)
    }
}