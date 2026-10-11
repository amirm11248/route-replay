import Foundation
import HealthKit
import CoreLocation

/// Local-only workouts used to exercise the app without requesting HealthKit
/// access. Keeping these outside HealthKit makes the test path deterministic,
/// fast, and safe to use on a fresh simulator or device.
enum ExampleWorkoutData {

    private static let referenceDate = Date()

    private static let runID = UUID(uuidString: "D9DB4A42-6D9A-4AAB-8E1A-0D24DDB3A101")!
    private static let walkID = UUID(uuidString: "D9DB4A42-6D9A-4AAB-8E1A-0D24DDB3A102")!
    private static let cycleID = UUID(uuidString: "D9DB4A42-6D9A-4AAB-8E1A-0D24DDB3A103")!
    private static let hikeID = UUID(uuidString: "D9DB4A42-6D9A-4AAB-8E1A-0D24DDB3A104")!

    /// Stable routes make UI tests and relaunches behave the same way every
    /// time. The Berlin run follows real streets from Brandenburg Gate along
    /// Unter den Linden and Karl-Liebknecht-Straße to the TV Tower; the other
    /// examples remain deliberately curved so replay camera turns are visible.
    /// The New York run uses the mapped Reservoir running track vertices.
    static let routesByID: [UUID: [CLLocation]] = [
        NewYorkReservoirRoute.workoutID: pathRoute(
            waypoints: NewYorkReservoirRoute.waypoints,
            start: referenceDate.addingTimeInterval(-86_400),
            duration: 960,
            altitude: 37
        ),
        runID: pathRoute(
            waypoints: [
                // Brandenburger Tor / Pariser Platz.
                CLLocationCoordinate2D(latitude: 52.5162699, longitude: 13.3777034),
                CLLocationCoordinate2D(latitude: 52.516340, longitude: 13.378236),
                CLLocationCoordinate2D(latitude: 52.516181, longitude: 13.378265),
                // Unter den Linden, heading east.
                CLLocationCoordinate2D(latitude: 52.516266, longitude: 13.379528),
                CLLocationCoordinate2D(latitude: 52.516552, longitude: 13.383988),
                CLLocationCoordinate2D(latitude: 52.516865, longitude: 13.388849),
                CLLocationCoordinate2D(latitude: 52.517185, longitude: 13.393173),
                CLLocationCoordinate2D(latitude: 52.517349, longitude: 13.395146),
                CLLocationCoordinate2D(latitude: 52.517543, longitude: 13.398189),
                // Schlossplatz, Liebknechtbrücke, then Karl-Liebknecht-Straße.
                CLLocationCoordinate2D(latitude: 52.517587, longitude: 13.398930),
                CLLocationCoordinate2D(latitude: 52.518251, longitude: 13.401080),
                CLLocationCoordinate2D(latitude: 52.518612, longitude: 13.402031),
                CLLocationCoordinate2D(latitude: 52.518873, longitude: 13.402702),
                CLLocationCoordinate2D(latitude: 52.519379, longitude: 13.403758),
                CLLocationCoordinate2D(latitude: 52.519827, longitude: 13.404635),
                CLLocationCoordinate2D(latitude: 52.520343, longitude: 13.405629),
                CLLocationCoordinate2D(latitude: 52.520698, longitude: 13.406302),
                CLLocationCoordinate2D(latitude: 52.521236, longitude: 13.407369),
                CLLocationCoordinate2D(latitude: 52.521817, longitude: 13.408531),
                CLLocationCoordinate2D(latitude: 52.522198, longitude: 13.409286),
                // Alexanderplatz plaza, finishing at the Fernsehturm.
                CLLocationCoordinate2D(latitude: 52.522052, longitude: 13.409752),
                CLLocationCoordinate2D(latitude: 52.521443, longitude: 13.409902),
                CLLocationCoordinate2D(latitude: 52.5208279, longitude: 13.4094214),
            ],
            start: referenceDate.addingTimeInterval(-2 * 86_400),
            duration: 1_860,
            altitude: 36
        ),
        walkID: route(
            center: CLLocationCoordinate2D(latitude: 40.7710, longitude: -73.9710),
            latitudeRadius: 0.006,
            longitudeRadius: 0.010,
            turns: 1.8,
            points: 150,
            start: referenceDate.addingTimeInterval(-12 * 86_400),
            duration: 2_400,
            altitude: 18
        ),
        cycleID: route(
            center: CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945),
            latitudeRadius: 0.014,
            longitudeRadius: 0.022,
            turns: 1.15,
            points: 220,
            start: referenceDate.addingTimeInterval(-62 * 86_400),
            duration: 4_500,
            altitude: 52
        ),
        hikeID: route(
            center: CLLocationCoordinate2D(latitude: 46.8523, longitude: 9.5310),
            latitudeRadius: 0.018,
            longitudeRadius: 0.012,
            turns: 2.2,
            points: 210,
            start: referenceDate.addingTimeInterval(-104 * 86_400),
            duration: 5_400,
            altitude: 1_200
        ),
    ]

    static let entries: [WorkoutEntry] = [
        makeEntry(
            id: NewYorkReservoirRoute.workoutID,
            type: .running,
            daysAgo: 1,
            duration: 960,
            activeEnergy: 182,
            averageHeartRate: 138,
            maxHeartRate: 153,
            steps: 3_100,
            temperature: 18,
            humidity: 58,
            elevation: 6,
            routeName: "New York Run"
        ),
        makeEntry(
            id: runID,
            type: .running,
            daysAgo: 2,
            duration: 1_860,
            activeEnergy: 321,
            averageHeartRate: 134,
            maxHeartRate: 158,
            steps: 6_520,
            temperature: 22,
            humidity: 65,
            elevation: 47
        ),
        makeEntry(
            id: walkID,
            type: .walking,
            daysAgo: 12,
            duration: 2_400,
            activeEnergy: 142,
            averageHeartRate: 92,
            maxHeartRate: 108,
            steps: 3_400,
            temperature: nil,
            humidity: nil,
            elevation: 18
        ),
        makeEntry(
            id: cycleID,
            type: .cycling,
            daysAgo: 62,
            duration: 4_500,
            activeEnergy: 512,
            averageHeartRate: 138,
            maxHeartRate: 162,
            steps: nil,
            temperature: 28,
            humidity: 55,
            elevation: 120
        ),
        makeEntry(
            id: hikeID,
            type: .hiking,
            daysAgo: 104,
            duration: 5_400,
            activeEnergy: 680,
            averageHeartRate: 118,
            maxHeartRate: 145,
            steps: 9_500,
            temperature: 19,
            humidity: 72,
            elevation: 340
        ),
    ]

    static func route(for workoutID: UUID) -> [CLLocation]? {
        routesByID[workoutID]
    }

    static func heartRateSamples(for workoutID: UUID) -> [HKQuantitySample] {
        guard let entry = entries.first(where: { $0.id == workoutID }) else { return [] }
        guard let average = entry.averageHeartRate, let maximum = entry.maxHeartRate else { return [] }

        let unit = HKUnit.count().unitDivided(by: .minute())
        let interval: TimeInterval = 30
        let count = max(Int(entry.duration / interval), 2)
        return (0..<count).map { index in
            let progress = Double(index) / Double(count - 1)
            let wave = sin(progress * .pi * 2) * (maximum - average) * 0.45
            let value = min(max(average + wave, average - 8), maximum)
            let start = entry.startDate.addingTimeInterval(Double(index) * interval)
            return HKQuantitySample(
                type: HKQuantityType(.heartRate),
                quantity: HKQuantity(unit: unit, doubleValue: value),
                start: start,
                end: start.addingTimeInterval(interval)
            )
        }
    }

    private static func makeEntry(
        id: UUID,
        type: HKWorkoutActivityType,
        daysAgo: Int,
        duration: TimeInterval,
        activeEnergy: Double,
        averageHeartRate: Double?,
        maxHeartRate: Double?,
        steps: Int?,
        temperature: Double?,
        humidity: Double?,
        elevation: Double,
        routeName: String? = nil
    ) -> WorkoutEntry {
        let start = referenceDate.addingTimeInterval(-Double(daysAgo) * 86_400)
        let distance = routesByID[id].map(RouteGeometry.length(of:))
        return WorkoutEntry(
            id: id,
            workoutType: type,
            startDate: start,
            endDate: start.addingTimeInterval(duration),
            duration: duration,
            distance: distance,
            activeEnergy: activeEnergy,
            totalEnergy: activeEnergy * 1.45,
            averageHeartRate: averageHeartRate,
            maxHeartRate: maxHeartRate,
            steps: steps,
            weatherTemperature: temperature,
            weatherHumidity: humidity,
            elevationGain: elevation,
            routeName: routeName
        )
    }

    private static func route(
        center: CLLocationCoordinate2D,
        latitudeRadius: Double,
        longitudeRadius: Double,
        turns: Double,
        points: Int,
        start: Date,
        duration: TimeInterval,
        altitude: Double
    ) -> [CLLocation] {
        guard points > 1 else { return [] }
        return (0..<points).map { index in
            let progress = Double(index) / Double(points - 1)
            let angle = progress * .pi * 2 * turns
            let latitude = center.latitude
                + sin(angle) * latitudeRadius
                + sin(progress * .pi * 5) * latitudeRadius * 0.08
            let longitude = center.longitude
                + cos(angle) * longitudeRadius
                + sin(progress * .pi * 3) * longitudeRadius * 0.06
            return CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                altitude: altitude + sin(angle * 1.7) * 12,
                horizontalAccuracy: 5,
                verticalAccuracy: 6,
                timestamp: start.addingTimeInterval(duration * progress)
            )
        }
    }

    /// Densifies path segments into GPS-like fixes, preserving every vertex.
    /// Distance-based timestamps keep playback speed consistent through bends.
    private static func pathRoute(
        waypoints: [CLLocationCoordinate2D],
        start: Date,
        duration: TimeInterval,
        altitude: Double
    ) -> [CLLocation] {
        guard waypoints.count > 1 else { return [] }

        var denseCoordinates: [CLLocationCoordinate2D] = [waypoints[0]]
        for (from, to) in zip(waypoints, waypoints.dropFirst()) {
            let fromLocation = CLLocation(coordinate: from, altitude: altitude, horizontalAccuracy: 5, verticalAccuracy: 6, timestamp: start)
            let toLocation = CLLocation(coordinate: to, altitude: altitude, horizontalAccuracy: 5, verticalAccuracy: 6, timestamp: start)
            let segmentDistance = fromLocation.distance(from: toLocation)
            let steps = max(Int(ceil(segmentDistance / 10)), 1)

            for step in 1...steps {
                let progress = Double(step) / Double(steps)
                denseCoordinates.append(CLLocationCoordinate2D(
                    latitude: from.latitude + (to.latitude - from.latitude) * progress,
                    longitude: from.longitude + (to.longitude - from.longitude) * progress
                ))
            }
        }

        let timestampedBase = denseCoordinates.map {
            CLLocation(coordinate: $0, altitude: altitude, horizontalAccuracy: 5, verticalAccuracy: 6, timestamp: start)
        }
        let totalDistance = RouteGeometry.length(of: timestampedBase)
        guard totalDistance > 0 else { return timestampedBase }

        var traveled = 0.0
        return timestampedBase.enumerated().map { index, location in
            if index > 0 {
                traveled += timestampedBase[index - 1].distance(from: location)
            }
            let progress = traveled / totalDistance
            return CLLocation(
                coordinate: location.coordinate,
                altitude: altitude + sin(progress * .pi * 2) * 3,
                horizontalAccuracy: 5,
                verticalAccuracy: 6,
                timestamp: start.addingTimeInterval(duration * progress)
            )
        }
    }
}
