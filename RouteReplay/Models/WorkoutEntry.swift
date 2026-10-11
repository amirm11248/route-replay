import Foundation
import HealthKit

/// A lightweight, display-ready snapshot of an `HKWorkout` plus derived metrics.
struct WorkoutEntry: Identifiable, Hashable {
    let id: UUID
    let workoutType: HKWorkoutActivityType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval

    // Metrics (nil when HealthKit doesn't have them for this workout)
    let distance: Double?           // meters
    let activeEnergy: Double?       // kcal
    let totalEnergy: Double?        // kcal
    let averageHeartRate: Double?   // bpm
    let maxHeartRate: Double?       // bpm
    let steps: Int?
    let weatherTemperature: Double? // °C
    let weatherHumidity: Double?    // %

    /// Loaded from the route when imported or lazily by the detail view.
    var elevationGain: Double?      // meters

    /// Optional title for a named example route. Health imports use the activity name.
    var routeName: String? = nil

    /// Imported entries are route-backed. Distance is used here instead of
    /// elevation because a perfectly valid route can be completely flat.
    var hasGPSRoute: Bool { (distance ?? 0) > 0 }

    // MARK: - Display helpers

    var displayName: String {
        routeName ?? WorkoutTypeStyling.name(for: workoutType)
    }

    var symbolName: String {
        WorkoutTypeStyling.symbol(for: workoutType)
    }

    var tintColor: (red: Double, green: Double, blue: Double) {
        WorkoutTypeStyling.color(for: workoutType)
    }

    var dateString: String {
        Self.dateFormatter.string(from: startDate)
    }

    var timeString: String {
        Self.timeFormatter.string(from: startDate)
    }

    var monthKey: String {
        Self.monthFormatter.string(from: startDate)
    }

    var durationString: String {
        Self.durationFormatter.string(from: duration) ?? "--"
    }

    var distanceString: String {
        guard let distance, distance > 0 else { return "--" }
        return Measurement(value: distance, unit: UnitLength.meters)
            .converted(to: .kilometers)
            .formatted(.measurement(width: .abbreviated, usage: .road, numberFormatStyle: .number.precision(.fractionLength(2))))
    }

    /// Seconds per kilometer.
    var paceSecondsPerKM: Double? {
        guard let distance, distance > 10, duration > 0 else { return nil }
        return duration / (distance / 1000)
    }

    var paceString: String {
        guard let pace = paceSecondsPerKM else { return "--" }
        let total = Int(pace.rounded())
        return String(format: "%d:%02d /km", total / 60, total % 60)
    }

    // MARK: - Formatters

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    private static let durationFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.unitsStyle = .abbreviated
        f.zeroFormattingBehavior = .dropLeading
        return f
    }()
}

/// Style mapping (symbol + color) for workout activity types.
enum WorkoutTypeStyling {
    /// Activities that are not meaningful map replays even if a third-party
    /// source happens to attach a location sample to them.
    static func supportsRouteReplay(_ type: HKWorkoutActivityType) -> Bool {
        switch type {
        case .functionalStrengthTraining, .traditionalStrengthTraining, .coreTraining,
             .yoga, .mindAndBody, .highIntensityIntervalTraining, .elliptical,
             .stairClimbing:
            return false
        default:
            return true
        }
    }

    static func name(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "Run"
        case .walking: return "Walk"
        case .cycling: return "Cycle"
        case .hiking: return "Hike"
        case .swimming: return "Swim"
        case .rowing: return "Row"
        case .elliptical: return "Elliptical"
        case .highIntensityIntervalTraining: return "HIIT"
        case .stairClimbing: return "Stair Stepper"
        case .functionalStrengthTraining: return "Functional Strength"
        case .traditionalStrengthTraining: return "Strength"
        case .yoga: return "Yoga"
        case .coreTraining: return "Core Training"
        case .tennis: return "Tennis"
        case .soccer: return "Soccer"
        case .downhillSkiing: return "Skiing"
        case .snowboarding: return "Snowboarding"
        case .crossCountrySkiing: return "Cross-Country Skiing"
        case .paddleSports: return "Paddle Sports"
        case .skatingSports: return "Skating"
        case .sailing: return "Sailing"
        case .surfingSports: return "Surfing"
        case .wheelchairRunPace: return "Wheelchair Run"
        case .wheelchairWalkPace: return "Wheelchair Walk"
        default: return "Workout"
        }
    }

    static func symbol(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .hiking: return "figure.hiking"
        case .swimming: return "figure.pool.swim"
        case .rowing: return "figure.rower"
        case .elliptical: return "figure.elliptical"
        case .highIntensityIntervalTraining: return "figure.highintensity.intervaltraining"
        case .stairClimbing: return "figure.stair.stepper"
        case .functionalStrengthTraining: return "figure.strengthtraining.functional"
        case .traditionalStrengthTraining: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .coreTraining: return "figure.core.training"
        case .tennis: return "figure.tennis"
        case .soccer: return "figure.soccer"
        case .downhillSkiing: return "figure.skiing.downhill"
        case .snowboarding: return "figure.snowboarding"
        case .crossCountrySkiing: return "figure.skiing.crosscountry"
        case .paddleSports: return "figure.canoeing"
        case .skatingSports: return "figure.skating"
        case .sailing: return "figure.sailing"
        case .surfingSports: return "figure.surfing"
        default: return "figure.mixed.cardio"
        }
    }

    /// Returns an RGB color per activity type.
    static func color(for type: HKWorkoutActivityType) -> (red: Double, green: Double, blue: Double) {
        switch type {
        case .running, .wheelchairRunPace: return (0.98, 0.30, 0.18)   // red-orange
        case .cycling: return (0.08, 0.58, 0.96)                        // blue
        case .walking, .wheelchairWalkPace: return (0.22, 0.58, 0.94)   // blue
        case .hiking: return (0.24, 0.62, 0.33)                         // green
        case .swimming: return (0.10, 0.65, 0.85)                       // cyan
        case .rowing, .elliptical, .highIntensityIntervalTraining: return (0.90, 0.33, 0.66) // pink
        case .yoga, .mindAndBody: return (0.55, 0.42, 0.86)             // purple
        case .functionalStrengthTraining, .traditionalStrengthTraining, .coreTraining: return (0.62, 0.43, 0.28) // brown-ish
        case .snowSports, .downhillSkiing, .snowboarding, .crossCountrySkiing: return (0.40, 0.75, 0.95)
        default: return (0.45, 0.50, 0.58)                              // gray
        }
    }
}
