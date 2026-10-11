import SwiftUI
import CoreLocation
import HealthKit

// MARK: - Mock data for Previews and DEBUG verification

#if DEBUG
enum MockData {
    static let route: [CLLocation] = {
        let center = CLLocationCoordinate2D(latitude: 40.7710, longitude: -73.9710)
        return (0..<300).map { i in
            let angle = (Double(i) / 300) * 2 * .pi
            let lat = center.latitude + sin(angle) * 0.0115
            let lon = center.longitude + cos(angle) * 0.0060
            let alt = 18.0 + sin(angle * 3) * 6
            return CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                altitude: alt,
                horizontalAccuracy: 5,
                verticalAccuracy: 5,
                timestamp: Date().addingTimeInterval(TimeInterval(i * 10))
            )
        }
    }()

    static var entry: WorkoutEntry {
        WorkoutEntry(
            id: UUID(),
            workoutType: .running,
            startDate: Date().addingTimeInterval(-86400 * 2),
            endDate: Date().addingTimeInterval(-86400 * 2 + 1860),
            duration: 1860,
            distance: 5_420,
            activeEnergy: 321,
            totalEnergy: 486,
            averageHeartRate: 134,
            maxHeartRate: 158,
            steps: 6520,
            weatherTemperature: 22,
            weatherHumidity: 65,
            elevationGain: 47
        )
    }

    static var walkEntry: WorkoutEntry {
        WorkoutEntry(
            id: UUID(),
            workoutType: .walking,
            startDate: Date().addingTimeInterval(-86400 * 12),
            endDate: Date().addingTimeInterval(-86400 * 12 + 2400),
            duration: 2400,
            distance: 2_800,
            activeEnergy: 142,
            totalEnergy: 210,
            averageHeartRate: 92,
            maxHeartRate: 108,
            steps: 3400,
            weatherTemperature: nil,
            weatherHumidity: nil,
            elevationGain: 18
        )
    }

    static let heartRateSamples: [HKQuantitySample] = {
        let unit = HKUnit.count().unitDivided(by: .minute())
        return (0..<60).map { i in
            let value = 120.0 + sin(Double(i) / 60 * .pi * 2) * 25 + Double.random(in: -5...5)
            let time = Date().addingTimeInterval(-86400 * 2 + Double(i * 30))
            return HKQuantitySample(
                type: HKQuantityType(.heartRate),
                quantity: HKQuantity(unit: unit, doubleValue: value),
                start: time,
                end: time.addingTimeInterval(30)
            )
        }
    }()

    static var entries: [WorkoutEntry] {
        [
            entry,
            walkEntry,
            WorkoutEntry(id: UUID(), workoutType: .cycling, startDate: Date().addingTimeInterval(-86400 * 62), endDate: Date().addingTimeInterval(-86400 * 62 + 4500), duration: 4500, distance: 18_200, activeEnergy: 512, totalEnergy: 685, averageHeartRate: 138, maxHeartRate: 162, steps: nil, weatherTemperature: 28, weatherHumidity: 0.55, elevationGain: 120),
            WorkoutEntry(id: UUID(), workoutType: .hiking, startDate: Date().addingTimeInterval(-86400 * 104), endDate: Date().addingTimeInterval(-86400 * 104 + 9000), duration: 9000, distance: 8_400, activeEnergy: 680, totalEnergy: 890, averageHeartRate: 118, maxHeartRate: 145, steps: 9500, weatherTemperature: 19, weatherHumidity: 0.72, elevationGain: 340),
            WorkoutEntry(id: UUID(), workoutType: .swimming, startDate: Date().addingTimeInterval(-86400 * 200), endDate: Date().addingTimeInterval(-86400 * 200 + 2700), duration: 2700, distance: 1_500, activeEnergy: 280, totalEnergy: 350, averageHeartRate: 142, maxHeartRate: 168, steps: nil, weatherTemperature: nil, weatherHumidity: nil, elevationGain: nil),
        ]
    }
}

// MARK: - Previews

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(entry: MockData.entry)
            .environmentObject(HealthKitManager.shared)
    }
}

struct WorkoutStatsCard_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutStatsCard(
            entry: MockData.entry,
            heartRateSamples: MockData.heartRateSamples,
            elevationGain: 47
        )
        .padding(.horizontal)
        .previewLayout(.sizeThatFits)
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = HealthKitManager.shared
        manager.workouts = MockData.entries
        return WorkoutListView()
            .environmentObject(manager)
    }
}

struct WorkoutRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            WorkoutRow(entry: MockData.entry)
            WorkoutRow(entry: MockData.walkEntry)
        }
        .previewLayout(.sizeThatFits)
    }
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
            .environmentObject(HealthKitManager.shared)
    }
}
#endif