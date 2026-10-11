import SwiftUI
import HealthKit
import Charts

/// Integrated summary; the detail view owns the surface, detent, and replay action.
struct WorkoutStatsCard: View {
    let entry: WorkoutEntry
    let heartRateSamples: [HKQuantitySample]
    let elevationGain: Double?
    var expanded = true
    var compact = false
    var onToggleDetails: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var distanceFontSize = 52.0

    private var heartRateSeries: [(date: Date, bpm: Double)] {
        heartRateSamples.map {
            ($0.startDate, $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(AppTheme.line)
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, compact ? 10 : 16)
                .accessibilityHidden(true)
            if compact {
                compactSummary.padding(.horizontal, 22).padding(.bottom, 12)
            } else {
                header.padding(.horizontal, 22)
                majorStats.padding(.horizontal, 22).padding(.top, 20)
                supportingStats.padding(.horizontal, 22).padding(.top, 18)
                if let onToggleDetails {
                    Button(action: onToggleDetails) {
                        HStack {
                            Text(expanded ? "Less Detail" : "More Detail")
                            Spacer()
                            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        }
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondary)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("workout-more-details-button")
                    .accessibilityHint(expanded ? "Collapse the workout summary" : "Show energy, steps, and heart rate details")
                    .padding(.horizontal, 22)
                }
                if expanded {
                    extendedStats.padding(.horizontal, 22).padding(.bottom, 20)
                }
            }
        }
        .foregroundStyle(AppTheme.primary)
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                title
                Spacer(minLength: 8)
                weather
            }
            VStack(alignment: .leading, spacing: 10) {
                title
                weather
            }
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.displayName).font(.title2.weight(.semibold))
            Text(entry.startDate.formatted(.dateTime.day().month(.abbreviated).year()))
                .font(.caption).foregroundStyle(AppTheme.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var weather: some View {
        HStack(spacing: 10) {
            if let temperature = entry.weatherTemperature {
                Label("\(Int(temperature.rounded()))°C", systemImage: "cloud.sun")
                    .accessibilityLabel("Temperature \(Int(temperature.rounded())) degrees Celsius")
            }
            if let humidity = entry.weatherHumidity {
                Label("\(Int(humidity.rounded()))%", systemImage: "humidity")
                    .accessibilityLabel("Humidity \(Int(humidity.rounded())) percent")
            }
        }
        .font(.caption).foregroundStyle(AppTheme.secondary).fixedSize()
    }

    private var majorStats: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .lastTextBaseline, spacing: 30) {
                distanceMetric
                Spacer(minLength: 0)
                durationMetric
            }
            VStack(alignment: .leading, spacing: 18) {
                distanceMetric
                durationMetric
            }
        }
    }

    private var distanceMetric: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(distanceNumber)
                    .font(.system(size: distanceFontSize, weight: .medium))
                    .tracking(-2).monospacedDigit()
                Text("km").font(.subheadline).foregroundStyle(AppTheme.secondary)
            }
            Text("Distance").font(.caption).foregroundStyle(AppTheme.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Distance")
        .accessibilityValue(Self.distanceText(entry.distance))
    }

    private var durationMetric: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(Self.durationText(entry.duration)).font(.title.weight(.medium)).monospacedDigit()
            Text("Duration").font(.caption).foregroundStyle(AppTheme.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var supportingStats: some View {
        VStack(spacing: 14) {
            Rectangle().fill(AppTheme.line).frame(height: 1)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 145 : 90), alignment: .leading)], alignment: .leading, spacing: 16) {
                metric("Avg. Pace", value: entry.paceSecondsPerKM.map(Self.paceText) ?? "Not recorded", unit: entry.paceSecondsPerKM == nil ? "" : "/km")
                metric("Heart Rate", value: entry.averageHeartRate.map { Int($0.rounded()).formatted() } ?? "Not recorded", unit: entry.averageHeartRate == nil ? "" : "bpm")
                metric("Elevation", value: elevationGain.map { Int($0.rounded()).formatted() } ?? "Not recorded", unit: elevationGain == nil ? "" : "m")
            }
        }
    }

    private var extendedStats: some View {
        VStack(alignment: .leading, spacing: 18) {
            Rectangle().fill(AppTheme.line).frame(height: 1)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 145 : 130), alignment: .leading)], alignment: .leading, spacing: 18) {
                metric("Active Energy", value: Self.energyText(entry.activeEnergy))
                metric("Total Energy", value: Self.energyText(entry.totalEnergy))
                metric("Steps", value: entry.steps.map { $0.formatted() } ?? "Not recorded")
                if let maximum = entry.maxHeartRate {
                    metric("Max. Heart Rate", value: Int(maximum.rounded()).formatted(), unit: "bpm")
                }
            }
            if !heartRateSamples.isEmpty { heartRateChart }
        }
    }

    private func metric(_ label: String, value: String, unit: String = "") -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value).font(.title3.weight(.medium)).monospacedDigit()
                if !unit.isEmpty { Text(unit).font(.caption).foregroundStyle(AppTheme.secondary) }
            }
            Text(label).font(.caption).foregroundStyle(AppTheme.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(unit.isEmpty ? value : "\(value) \(unit)")
    }

    private var compactSummary: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.symbolName).font(.title3).foregroundStyle(AppTheme.accent).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.displayName).font(.subheadline.weight(.semibold))
                Text(Self.durationText(entry.duration)).font(.caption).foregroundStyle(AppTheme.secondary)
            }
            Spacer(minLength: 8)
            Text(Self.distanceText(entry.distance)).font(.title3.weight(.medium)).monospacedDigit()
        }
    }

    private var heartRateChart: some View {
        let series = heartRateSeries
        let baseline = (series.map(\.bpm).min() ?? 0) - 10
        return VStack(alignment: .leading, spacing: 10) {
            Text("Heart Rate").font(.subheadline.weight(.semibold))
            if series.count >= 2 {
                Chart(series, id: \.date) { point in
                    LineMark(x: .value("Time", point.date), y: .value("BPM", point.bpm))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(AppTheme.accent)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    AreaMark(x: .value("Time", point.date), yStart: .value("Baseline", baseline), yEnd: .value("BPM", point.bpm))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(AppTheme.accent.opacity(0.10))
                }
                .chartYScale(domain: Self.chartYDomain(series.map(\.bpm)))
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                        AxisGridLine().foregroundStyle(AppTheme.line)
                        AxisValueLabel().font(.caption2).foregroundStyle(AppTheme.secondary)
                    }
                }
                .frame(height: 100)
                .accessibilityLabel("Heart rate over the workout")
            }
        }
    }

    private var distanceNumber: String {
        guard let distance = entry.distance, distance > 0 else { return "Not recorded" }
        return (distance / 1000).formatted(.number.precision(.fractionLength(2)))
    }

    private static func chartYDomain(_ values: [Double]) -> ClosedRange<Double> {
        guard let minimum = values.min(), let maximum = values.max(), maximum > minimum else { return 40...200 }
        let padding = (maximum - minimum) * 0.3
        return (minimum - padding)...(maximum + padding)
    }

    static func durationText(_ duration: TimeInterval) -> String {
        let total = Int(duration.rounded()), hours = total / 3600, minutes = (total % 3600) / 60, seconds = total % 60
        return hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, seconds) : String(format: "%d:%02d", minutes, seconds)
    }

    private static func paceText(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    static func distanceText(_ meters: Double?) -> String {
        guard let meters, meters > 0 else { return "Not recorded" }
        return "\((meters / 1000).formatted(.number.precision(.fractionLength(2)))) km"
    }

    static func energyText(_ kcal: Double?) -> String {
        guard let kcal, kcal > 0 else { return "Not recorded" }
        return "\(Int(kcal.rounded()).formatted()) kcal"
    }

    static func elevationText(_ meters: Double?) -> String {
        guard let meters else { return "Not recorded" }
        return "\(Int(meters.rounded()).formatted()) m"
    }
}
