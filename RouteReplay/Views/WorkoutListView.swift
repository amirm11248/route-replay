import SwiftUI

/// The workout library: every synced workout grouped by month.
struct WorkoutListView: View {
    @EnvironmentObject private var health: HealthKitManager
    @State private var searchText = ""
    @State private var showingDetails: WorkoutEntry?
    @State private var showingSettings = false

    private var groupedWorkouts: [(month: String, workouts: [WorkoutEntry])] {
        let filtered = filteredWorkouts
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filtered) { entry -> String in
            let comps = calendar.dateComponents([.year, .month], from: entry.startDate)
            return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
        }
        return groups
            .sorted { $0.key > $1.key }
            .compactMap { key, entries -> (String, [WorkoutEntry])? in
                guard let date = key.toDate() else { return nil }
                return (WorkoutEntry.monthTitle(for: date), entries)
            }
    }

    private var filteredWorkouts: [WorkoutEntry] {
        guard !searchText.isEmpty else { return health.workouts }
        return health.workouts.filter { entry in
            entry.displayName.localizedCaseInsensitiveContains(searchText)
                || entry.dateString.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var totalDistance: Measurement<UnitLength> {
        let meters = health.workouts.compactMap(\.distance).reduce(0, +)
        return Measurement(value: meters, unit: UnitLength.meters)
    }

    var body: some View {
        NavigationStack {
            Group {
                if health.isLoading && health.workouts.isEmpty {
                    ProgressView("Importing workouts…")
                        .font(.system(.body, design: .default))
                } else if health.workouts.isEmpty {
                    emptyState
                } else if filteredWorkouts.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    workoutList
                }
            }
            .background(AppTheme.background)
            .navigationTitle("")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await health.syncWithAppleHealth() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(health.isLoading)
                    .accessibilityLabel("Sync with Apple Health")
                    .accessibilityIdentifier("sync-health-button")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityIdentifier("settings-button")
                }
            }
        }
        .fullScreenCover(item: $showingDetails) { entry in
            WorkoutDetailView(entry: entry)
        }
        .sheet(isPresented: $showingSettings) {
            AppSettingsView()
                .environmentObject(health)
        }
        .task {
            if health.workouts.isEmpty && health.isUsingExampleWorkouts {
                health.loadExampleWorkouts()
            } else if health.workouts.isEmpty && health.isAuthorized {
                await health.importWorkouts()
            }
            #if DEBUG
            // UI-test hook: auto-open the most recent workout's detail screen.
            // Falls back to a bundled demo workout when HealthKit has no data
            // (e.g. the permission sheet hasn't been accepted yet).
            if ProcessInfo.processInfo.environment["AUTOSEED_DETAIL"] == "1", showingDetails == nil {
                if let first = health.workouts.first {
                    showingDetails = first
                } else {
                    showingDetails = MockData.entry
                }
                print("[AUTOSEED_DETAIL] opening detail, workouts= \(health.workouts.count)")
            }
            #endif
        }
    }

    // MARK: - List

    private var workoutList: some View {
        List {
            summaryHeader
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ForEach(groupedWorkouts, id: \.month) { group in
                Section {
                    ForEach(group.workouts) { entry in
                        Button {
                            showingDetails = entry
                        } label: {
                            WorkoutRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("workout-row")
                        .listRowBackground(AppTheme.background)
                        .listRowSeparatorTint(AppTheme.line)
                        .listRowInsets(EdgeInsets(top: 8, leading: 22, bottom: 8, trailing: 22))
                    }
                } header: {
                    monthHeader(group)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .refreshable {
            await health.importWorkouts()
        }
    }

    private func monthHeader(_ group: (month: String, workouts: [WorkoutEntry])) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(group.month)
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundStyle(AppTheme.primary)
            Spacer()
            let count = group.workouts.count
            let meters = group.workouts.compactMap(\.distance).reduce(0, +)
            Text("\(count) workout\(count == 1 ? "" : "s") · \(Self.distanceCaption(meters))")
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundStyle(AppTheme.secondary)
        }
        .textCase(nil)
        .padding(.top, 6)
    }

    private var summaryHeader: some View {
        let totalMinutes = health.workouts.reduce(0) { $0 + Int($1.duration / 60) }
        let bestPace = health.workouts.compactMap(\.paceSecondsPerKM).min()
        return VStack(alignment: .leading, spacing: 18) {
            Text("Workouts")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(AppTheme.primary)
                .accessibilityAddTraits(.isHeader)
            Text(Self.distanceSummary(totalDistance))
                .font(.title.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(AppTheme.primary)
            Text("Total distance")
                .font(.caption)
                .foregroundStyle(AppTheme.secondary)
                .padding(.top, -12)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 24) {
                    summaryMetric(value: health.workouts.count.formatted(), label: "Workouts")
                    summaryMetric(value: totalMinutes.formatted(), label: "Minutes")
                    summaryMetric(value: bestPace.map(Self.paceShort) ?? "Not recorded", label: "Best Pace")
                }
                VStack(alignment: .leading, spacing: 16) {
                    summaryMetric(value: health.workouts.count.formatted(), label: "Workouts")
                    summaryMetric(value: totalMinutes.formatted(), label: "Minutes")
                    summaryMetric(value: bestPace.map(Self.paceShort) ?? "Not recorded", label: "Best Pace")
                }
            }
            Rectangle().fill(AppTheme.line).frame(height: 1)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    private func summaryMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value).font(.title3.weight(.medium)).monospacedDigit().foregroundStyle(AppTheme.primary)
            Text(label).font(.caption).foregroundStyle(AppTheme.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.surface)
                    .frame(width: 110, height: 110)
                Image(systemName: "figure.walk")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }
            Text("No workouts yet")
                .font(.system(size: 22, weight: .bold, design: .default))
            Text("Workouts recorded on your Apple Watch with GPS will appear here. Indoor and strength workouts are hidden.")
                .font(.system(size: 15, design: .default))
                .foregroundStyle(AppTheme.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            if let error = health.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Button {
                Task { await health.syncWithAppleHealth() }
            } label: {
                Label("Sync with Apple Health", systemImage: "heart.text.square")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .padding(.horizontal, 18)
            }
            .buttonStyle(ReplayActionButtonStyle())
            .padding(.horizontal, 28)
            .accessibilityIdentifier("empty-sync-health-button")
        }
    }

    // MARK: - Formatting helpers

    private static func distanceCaption(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }

    private static func paceShort(_ secondsPerKM: Double) -> String {
        let total = Int(secondsPerKM.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    private static func distanceSummary(_ distance: Measurement<UnitLength>) -> String {
        let km = distance.converted(to: .kilometers).value
        if km >= 100 { return String(format: "%.0f km", km) }
        if km >= 10 { return String(format: "%.1f km", km) }
        return String(format: "%.2f km", km)
    }
}

/// A single workout row: tinted icon, title, date, and trailing distance/time.
struct WorkoutRow: View {
    let entry: WorkoutEntry

    var body: some View {
        HStack(spacing: 14) {
            icon
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.displayName)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.primary)
                Text(entry.startDate.formatted(.dateTime.day().month(.abbreviated).hour().minute()))
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(AppTheme.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(WorkoutStatsCard.distanceText(entry.distance))
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.primary)
                Text(entry.durationString)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundStyle(AppTheme.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var icon: some View {
        Image(systemName: entry.symbolName)
            .font(.system(size: 21, weight: .medium))
            .foregroundStyle(AppTheme.accent)
            .frame(width: 46, height: 46)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
            .accessibilityHidden(true)
    }

}

// MARK: - Extensions

extension WorkoutEntry {
    static func monthTitle(for date: Date) -> String {
        Self.monthHeaderFormatter.string(from: date)
    }

    private static let monthHeaderFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
}

private extension String {
    func toDate() -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.date(from: self)
    }
}
