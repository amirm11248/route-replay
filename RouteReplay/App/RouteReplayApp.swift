import SwiftUI

@main
struct RouteReplayApp: App {
    @StateObject private var health = HealthKitManager.shared
    @AppStorage("appAppearance") private var appearance = AppAppearance.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(health)
                .tint(AppTheme.accent)
                .preferredColorScheme(AppAppearance(rawValue: appearance)?.colorScheme)
        }
    }
}
