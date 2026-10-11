import Foundation
import HealthKit
import CoreLocation

/// Central gateway for both supported workout sources: local example data and
/// read-only Apple Health data. The source is explicit so testing never needs
/// to request HealthKit write access and syncing never accidentally leaves
/// stale example workouts on screen.
@MainActor
final class HealthKitManager: ObservableObject {

    static let shared = HealthKitManager()

    private enum PreferenceKey {
        static let exampleMode = "routeReplay.exampleMode"
        static let healthConnected = "routeReplay.healthConnected"
    }

    private let store = HKHealthStore()
    private let defaults = UserDefaults.standard

    /// Original HealthKit workouts keyed by UUID, used to resolve routes and
    /// heart-rate samples after the visible list has been filtered.
    private var workoutSamples: [UUID: HKWorkout] = [:]

    /// Route locations per workout UUID. Example routes use the same cache, so
    /// detail and replay screens do not need to know which source is active.
    private var routeCache: [UUID: [CLLocation]] = [:]

    /// Heart-rate samples per workout UUID.
    private var heartRateCache: [UUID: [HKQuantitySample]] = [:]

    /// Prevents a slow HealthKit import from overwriting a newly selected
    /// example source if the user switches modes while it is in flight.
    private var sourceGeneration = 0

    /// This means HealthKit authorization completed successfully. HealthKit
    /// intentionally does not expose read-permission status, so checking
    /// `authorizationStatus(for:)` on a read-only request is incorrect.
    @Published var isAuthorized: Bool

    /// Persisted separately so the settings screen can show the current
    /// source and keep the sync action available while examples are active.
    @Published var isAppleHealthConnected: Bool
    @Published var isUsingExampleWorkouts: Bool

    @Published var workouts: [WorkoutEntry]
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isReady: Bool { isAuthorized || isUsingExampleWorkouts }
    var isHealthDataAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    init() {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-RESET_ROUTE_REPLAY_SOURCE") {
            defaults.removeObject(forKey: PreferenceKey.exampleMode)
            defaults.removeObject(forKey: PreferenceKey.healthConnected)
        }
#endif
        let exampleMode = defaults.bool(forKey: PreferenceKey.exampleMode)
        let healthConnected = defaults.bool(forKey: PreferenceKey.healthConnected)

        self.isUsingExampleWorkouts = exampleMode
        self.isAppleHealthConnected = healthConnected
        self.isAuthorized = healthConnected
        self.workouts = exampleMode ? ExampleWorkoutData.entries : []

        if exampleMode {
            self.routeCache = ExampleWorkoutData.routesByID
        }
    }

    // MARK: - Session restoration

    /// Restores the last selected source on launch. Example mode is entirely
    /// local; a previously connected HealthKit source is imported again so
    /// the library is populated after the app has been terminated.
    func restoreSession() async {
        if isUsingExampleWorkouts {
            loadExampleWorkouts()
            return
        }

        guard isAppleHealthConnected else { return }
        isAuthorized = true
        await importWorkouts()
    }

    // MARK: - Authorization and source switching

    /// Requests only the read permissions needed by the library. A successful
    /// request is the only reliable signal available for read authorization;
    /// `authorizationStatus(for:)` describes sharing permission, not reading.
    func requestAuthorization() async -> Bool {
        guard isHealthDataAvailable else {
            errorMessage = "Health data isn't available on this device."
            return false
        }

        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            isAppleHealthConnected = true
            defaults.set(true, forKey: PreferenceKey.healthConnected)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Switches from local examples to the real HealthKit source only after
    /// authorization succeeds. If the request fails, the working examples
    /// remain visible and usable.
    @discardableResult
    func syncWithAppleHealth() async -> Bool {
        let granted = await requestAuthorization()
        guard granted else { return false }

        isUsingExampleWorkouts = false
        sourceGeneration &+= 1
        defaults.set(false, forKey: PreferenceKey.exampleMode)
        clearImportedData()
        await importWorkouts()
        return true
    }

    /// Loads bundled workouts without touching HealthKit. This is intentionally
    /// public so the permission screen and settings screen share one action.
    func loadExampleWorkouts() {
        sourceGeneration &+= 1
        isUsingExampleWorkouts = true
        defaults.set(true, forKey: PreferenceKey.exampleMode)
        workouts = ExampleWorkoutData.entries
        routeCache = ExampleWorkoutData.routesByID
        workoutSamples.removeAll(keepingCapacity: true)
        heartRateCache.removeAll(keepingCapacity: true)
        errorMessage = nil
    }

    #if DEBUG
    /// Compatibility entry point for the existing UI-test launch hook. It no
    /// longer writes synthetic workouts into HealthKit or asks for write access.
    func loadSampleData() async {
        loadExampleWorkouts()
    }
    #endif

    // MARK: - Workout import

    /// Imports only workouts with a genuine, usable GPS route. Indoor and
    /// route-less activities are intentionally omitted before publishing the
    /// list, so they can never flash into the UI and then disappear later.
    func importWorkouts() async {
        if isUsingExampleWorkouts {
            loadExampleWorkouts()
            return
        }
        guard isAuthorized, !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let importGeneration = sourceGeneration
        clearImportedData()

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let hkWorkouts: [HKWorkout] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: nil,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
            }
            store.execute(query)
        }

        guard !isUsingExampleWorkouts, importGeneration == sourceGeneration else { return }

        workoutSamples = Dictionary(uniqueKeysWithValues: hkWorkouts.map { ($0.uuid, $0) })

        var imported: [WorkoutEntry] = []
        imported.reserveCapacity(hkWorkouts.count)

        // Route queries are asynchronous and HealthKit may split one workout
        // into several route series. Reading them here once is slower than
        // mapping samples blindly, but prevents route-less workouts from ever
        // entering the visible library and avoids repeat queries on detail.
        for workout in hkWorkouts {
            guard !isUsingExampleWorkouts, importGeneration == sourceGeneration else { return }
            guard WorkoutTypeStyling.supportsRouteReplay(workout.workoutActivityType) else {
                continue
            }
            guard let locations = await loadRoute(for: workout),
                  RouteGeometry.hasUsableGPSData(locations) else {
                continue
            }
            imported.append(WorkoutEntryBuilder.build(from: workout))
        }

        workouts = imported
        if !hkWorkouts.isEmpty && imported.isEmpty {
            errorMessage = "No workouts with GPS routes were found. Indoor and strength workouts are hidden."
        }
    }

    // MARK: - Route loading

    /// Returns a cleaned, cached GPS route for a workout. Example routes are
    /// served locally and never fall through to HealthKit.
    func routeLocations(for workoutID: UUID) async -> [CLLocation]? {
        if let cached = routeCache[workoutID] { return cached }
        if let exampleRoute = ExampleWorkoutData.route(for: workoutID) {
            routeCache[workoutID] = exampleRoute
            return exampleRoute
        }
        guard isAuthorized, let sample = workoutSamples[workoutID] else { return nil }
        return await loadRoute(for: sample)
    }

    private func loadRoute(for workout: HKWorkout) async -> [CLLocation]? {
        if let cached = routeCache[workout.uuid] { return cached }

        let routes = await findRoutes(for: workout)
        guard !routes.isEmpty else { return nil }

        var locations: [CLLocation] = []
        for route in routes {
            locations.append(contentsOf: await readLocations(from: route))
        }

        let cleaned = RouteGeometry.cleanedGPSLocations(locations)
        guard RouteGeometry.hasUsableGPSData(cleaned) else { return nil }
        routeCache[workout.uuid] = cleaned
        return cleaned
    }

    private func findRoutes(for workout: HKWorkout) async -> [HKWorkoutRoute] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKSeriesType.workoutRoute(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKWorkoutRoute]) ?? [])
            }
            store.execute(query)
        }
    }

    private func readLocations(from route: HKWorkoutRoute) async -> [CLLocation] {
        await withCheckedContinuation { continuation in
            var all: [CLLocation] = []
            let query = HKWorkoutRouteQuery(route: route) { _, locations, done, _ in
                if let locations {
                    all.append(contentsOf: locations)
                }
                if done {
                    continuation.resume(returning: all)
                }
            }
            store.execute(query)
        }
    }

    // MARK: - Heart rate

    func heartRateSamples(for workoutID: UUID) async -> [HKQuantitySample] {
        if let cached = heartRateCache[workoutID] { return cached }
        if ExampleWorkoutData.route(for: workoutID) != nil {
            let samples = ExampleWorkoutData.heartRateSamples(for: workoutID)
            heartRateCache[workoutID] = samples
            return samples
        }
        guard isAuthorized, let sample = workoutSamples[workoutID] else { return [] }

        let type = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: sample.startDate,
            end: sample.endDate,
            options: .strictStartDate
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let samples: [HKQuantitySample] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
            }
            store.execute(query)
        }
        heartRateCache[workoutID] = samples
        return samples
    }

    // MARK: - Authorization types and cache lifecycle

    private var readTypes: Set<HKSampleType> {
        [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKQuantityType(.heartRate),
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceWheelchair),
            HKQuantityType(.distanceSwimming),
            HKQuantityType(.flightsClimbed),
        ]
    }

    private func clearImportedData() {
        workoutSamples.removeAll(keepingCapacity: true)
        routeCache.removeAll(keepingCapacity: true)
        heartRateCache.removeAll(keepingCapacity: true)
        if !isUsingExampleWorkouts {
            workouts.removeAll(keepingCapacity: true)
        }
    }
}

/// Builds a `WorkoutEntry` from an `HKWorkout` using its precomputed
/// statistics. Route presence is checked by `HealthKitManager` before this is
/// published, so this builder stays focused on metrics.
enum WorkoutEntryBuilder {

    static func build(from workout: HKWorkout) -> WorkoutEntry {
        let stats = { (id: HKQuantityTypeIdentifier) -> HKStatistics? in
            workout.statistics(for: HKQuantityType(id))
        }

        let active = stats(.activeEnergyBurned)?.sumQuantity()?
            .doubleValue(for: .kilocalorie())
        let resting = stats(.basalEnergyBurned)?.sumQuantity()?
            .doubleValue(for: .kilocalorie())

        let distance = Self.bestDistance(from: workout, stats: stats)

        let hrStats = stats(.heartRate)
        let averageHR = hrStats?.averageQuantity()?
            .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        let maxHR = hrStats?.maximumQuantity()?
            .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

        let stepCount = stats(.stepCount)?.sumQuantity()?
            .doubleValue(for: HKUnit.count())

        let temperature = workout.metadata?[HKMetadataKeyWeatherTemperature] as? HKQuantity
        let humidity = workout.metadata?[HKMetadataKeyWeatherHumidity] as? HKQuantity

        return WorkoutEntry(
            id: workout.uuid,
            workoutType: workout.workoutActivityType,
            startDate: workout.startDate,
            endDate: workout.endDate,
            duration: workout.duration,
            distance: distance,
            activeEnergy: active,
            totalEnergy: (active ?? 0) + (resting ?? 0),
            averageHeartRate: averageHR,
            maxHeartRate: maxHR,
            steps: stepCount.map { Int($0.rounded()) },
            weatherTemperature: temperature?.doubleValue(for: .degreeCelsius()),
            weatherHumidity: humidity?.doubleValue(for: .percent()),
            elevationGain: nil
        )
    }

    /// Distance stored for this workout can live under any of several quantity
    /// types depending on the activity; try them all.
    private static func bestDistance(
        from workout: HKWorkout,
        stats: (HKQuantityTypeIdentifier) -> HKStatistics?
    ) -> Double? {
        let candidates: [HKQuantityTypeIdentifier] = [
            .distanceWalkingRunning,
            .distanceCycling,
            .distanceWheelchair,
            .distanceSwimming,
            .distanceDownhillSnowSports,
        ]
        for id in candidates {
            if let distance = stats(id)?.sumQuantity()?
                .doubleValue(for: .meter()), distance > 0 {
                return distance
            }
        }
        if let total = workout.totalDistance {
            return total.doubleValue(for: .meter())
        }
        return nil
    }
}
