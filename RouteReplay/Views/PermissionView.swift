import SwiftUI

/// Explains the read-only Health connection and keeps the local example path.
struct PermissionView: View {
    @EnvironmentObject private var health: HealthKitManager
    @State private var isRequesting = false
    @State private var showError = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 24)
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                        .frame(width: 88, height: 88)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppTheme.line, lineWidth: 1))
                        .padding(.bottom, 28)
                        .accessibilityHidden(true)
                    Text("Route Replay")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(AppTheme.primary)
                        .padding(.bottom, 12)
                    Text("Relive every outdoor workout from your Apple Watch, on the map and in 3D.")
                        .font(.title3)
                        .foregroundStyle(AppTheme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 30)
                    VStack(alignment: .leading, spacing: 18) {
                        featureRow(icon: "map", text: "GPS routes from your Apple Watch")
                        featureRow(icon: "heart", text: "Heart rate, pace, elevation, calories & steps")
                        featureRow(icon: "view.3d", text: "Apple Maps 3D satellite replay")
                    }
                    .padding(.bottom, 34)
                    if health.isLoading {
                        HStack(spacing: 12) {
                            ProgressView().tint(AppTheme.accent)
                            Text("Importing workouts…").foregroundStyle(AppTheme.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                    } else {
                        Button {
                            Task { await connect() }
                        } label: {
                            Label("Allow & Sync Workouts", systemImage: "heart.text.square")
                        }
                        .buttonStyle(ReplayActionButtonStyle())
                        .disabled(isRequesting)
                        .opacity(isRequesting ? 0.6 : 1)
                        #if DEBUG
                        Button {
                            health.loadExampleWorkouts()
                        } label: {
                            Text("Test App with Example Workouts")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.accent)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("test-example-workouts-button")
                        .padding(.top, 10)
                        #endif
                    }
                    if !health.isHealthDataAvailable {
                        Text("Health data isn't available on this device.")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.secondary)
                            .padding(.top, 12)
                    }
                    Label("Health data stays on your iPhone. Route Replay has no app-owned server.", systemImage: "lock")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 22)
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 28)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
            .background(AppTheme.background.ignoresSafeArea())
        }
        .alert("Can't Connect", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(health.errorMessage ?? "Something went wrong while connecting to Health.")
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(text).font(.subheadline).foregroundStyle(AppTheme.primary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func connect() async {
        isRequesting = true
        defer { isRequesting = false }
        let granted = await health.syncWithAppleHealth()
        if !granted { showError = true }
    }
}
