import SwiftUI
import UIKit

/// Source and permission controls live in one place so example mode never
/// hides the Apple Health sync path.
struct AppSettingsView: View {
    @EnvironmentObject private var health: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appAppearance") private var appearance = AppAppearance.system.rawValue
    @State private var isSyncing = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("appearance-picker")
                    Text("Platinum in light mode. Onyx in dark mode.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondary)
                }
                .listRowBackground(AppTheme.surface)

                Section {
                    sourceRow

                    Button {
                        Task { await syncWithHealth() }
                    } label: {
                        Label("Sync with Apple Health", systemImage: "heart.text.square")
                    }
                    .disabled(isSyncing)
                    .accessibilityIdentifier("settings-sync-health-button")

                    #if DEBUG
                    if !health.isUsingExampleWorkouts {
                        Button {
                            health.loadExampleWorkouts()
                        } label: {
                            Label("Test App with Example Workouts", systemImage: "play.rectangle")
                        }
                        .accessibilityIdentifier("settings-test-examples-button")
                    }
                    #endif
                } header: {
                    Text("Workout source")
                } footer: {
                    Text("Only workouts with real GPS route data appear in the library. Indoor and strength workouts stay hidden.")
                }

                .listRowBackground(AppTheme.surface)

                Section("Apple Health") {
                    HStack(spacing: 12) {
                        Image(systemName: health.isAppleHealthConnected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(health.isAppleHealthConnected ? AppTheme.accent : AppTheme.secondary)
                        Text(health.isAppleHealthConnected ? "Connected for workout reading" : "Not connected")
                            .foregroundStyle(AppTheme.primary)
                    }

                    Button {
                        openHealthSettings()
                    } label: {
                        Label("Open Health Settings", systemImage: "arrow.up.forward.app")
                    }
                }

                .listRowBackground(AppTheme.surface)

                Section("Privacy") {
                    Text("Health data is processed on this device. Route Replay has no app-owned server, analytics, or advertising SDK. MapKit may load map content from Apple. Example workouts are bundled locally and do not use HealthKit.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondary)
                }
                .listRowBackground(AppTheme.surface)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .tint(AppTheme.accent)
            .navigationTitle("Settings")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if isSyncing {
                    ProgressView("Syncing workouts…")
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .alert("Couldn't sync Apple Health", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(health.errorMessage ?? "Please check Health permissions and try again.")
        }
    }

    private var sourceRow: some View {
        HStack(spacing: 12) {
            Image(systemName: health.isUsingExampleWorkouts ? "play.rectangle.fill" : "heart.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(health.isUsingExampleWorkouts ? "Example workouts" : "Apple Health workouts")
                    .font(.headline)
                Text(health.isUsingExampleWorkouts
                     ? "Local test data is active"
                     : "Synced workouts with GPS routes")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondary)
            }
        }
    }

    private func syncWithHealth() async {
        isSyncing = true
        let success = await health.syncWithAppleHealth()
        isSyncing = false
        if !success { showError = true }
    }

    private func openHealthSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
