import XCTest
import CoreLocation
@testable import RouteReplay

final class RouteGeometryTests: XCTestCase {

    private func loc(_ lat: Double, _ lon: Double) -> CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    func testLengthZeroForSinglePoint() {
        XCTAssertEqual(RouteGeometry.length(of: [loc(40, -74)]), 0, accuracy: 0.001)
    }

    func testLengthMatchesKnownMeters() {
        // 1 degree of latitude at 40°N ≈ 111,044 m (ellipsoidal Earth)
        let a = loc(40.0, -74.0)
        let b = loc(41.0, -74.0)
        XCTAssertEqual(RouteGeometry.length(of: [a, b]), 111_044, accuracy: 60)
    }

    func testBearingEastIs90() {
        let east = RouteGeometry.bearing(
            from: loc(40.0, -74.0).coordinate,
            to: loc(40.0, -73.0).coordinate
        )
        XCTAssertEqual(east, 90, accuracy: 1)
    }

    func testBearingNorthIs0() {
        let north = RouteGeometry.bearing(
            from: loc(40.0, -74.0).coordinate,
            to: loc(41.0, -74.0).coordinate
        )
        XCTAssertEqual(north, 0, accuracy: 1)
    }

    func testBearingSouthIs180() {
        let south = RouteGeometry.bearing(
            from: loc(40.0, -74.0).coordinate,
            to: loc(39.0, -74.0).coordinate
        )
        XCTAssertEqual(south, 180, accuracy: 1)
    }

    func testResampleSpacing() {
        let a = loc(40.0, -74.0)
        let b = loc(40.01, -74.0) // ~1,112 m apart
        let points = RouteGeometry.resample([a, b], spacing: 100)
        XCTAssertGreaterThan(points.count, 5)
        XCTAssertLessThan(points.count, 20)
        XCTAssertEqual(points.first?.latitude ?? 0, 40.0, accuracy: 0.000001)
        XCTAssertEqual(points.last?.latitude ?? 0, 40.01, accuracy: 0.000001)
    }

    func testPositionInterpolation() {
        let a = loc(40.0, -74.0)
        let b = loc(40.01, -74.0) // ~1,110 m apart
        let halfway = RouteGeometry.position(at: 555, along: [a, b])
        XCTAssertEqual(halfway.coordinate.latitude, 40.005, accuracy: 0.0001)
    }

    func testPositionAtEndReturnsLastPoint() {
        let a = loc(40.0, -74.0)
        let b = loc(40.01, -74.0)
        let end = RouteGeometry.position(at: 10_000_000, along: [a, b])
        XCTAssertEqual(end.coordinate.latitude, b.coordinate.latitude, accuracy: 0.0001)
    }

    func testSmoothHeadingShortestArc() {
        // From 350° to 10° should go +20°, not -340°.
        let result = RouteGeometry.smoothHeading(current: 350, target: 10)
        XCTAssertEqual(result, 354.4, accuracy: 0.5)
    }

    func testHeadingDeltaUsesShortestArc() {
        XCTAssertEqual(RouteGeometry.headingDelta(from: 350, to: 10), 20, accuracy: 0.001)
        XCTAssertEqual(RouteGeometry.headingDelta(from: 10, to: 350), -20, accuracy: 0.001)
    }

    func testInvalidGPSPointsAreRemoved() {
        let valid = loc(40, -74)
        let invalidAccuracy = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 40.001, longitude: -74),
            altitude: 0,
            horizontalAccuracy: -1,
            verticalAccuracy: 5,
            timestamp: Date()
        )
        let invalidCoordinate = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 200, longitude: -74),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            timestamp: Date()
        )

        let cleaned = RouteGeometry.cleanedGPSLocations([valid, invalidAccuracy, invalidCoordinate])
        XCTAssertEqual(cleaned.count, 1)
        XCTAssertFalse(RouteGeometry.hasUsableGPSData(cleaned))
    }

    func testExampleWorkoutsAllHaveGPSRoutes() {
        XCTAssertEqual(ExampleWorkoutData.entries.count, 5)
        XCTAssertTrue(ExampleWorkoutData.entries.allSatisfy { $0.hasGPSRoute })
        XCTAssertTrue(ExampleWorkoutData.entries.allSatisfy { entry in
            guard let route = ExampleWorkoutData.route(for: entry.id) else { return false }
            return RouteGeometry.hasUsableGPSData(route)
        })
    }

    func testBerlinRunExampleConnectsTheTwoLandmarks() {
        guard let entry = ExampleWorkoutData.entries.first(where: { $0.workoutType == .running && $0.routeName == nil }),
              let route = ExampleWorkoutData.route(for: entry.id),
              let first = route.first,
              let last = route.last else {
            return XCTFail("Berlin example run should have a route")
        }

        XCTAssertEqual(first.coordinate.latitude, 52.5162699, accuracy: 0.00001)
        XCTAssertEqual(first.coordinate.longitude, 13.3777034, accuracy: 0.00001)
        XCTAssertEqual(last.coordinate.latitude, 52.5208279, accuracy: 0.00001)
        XCTAssertEqual(last.coordinate.longitude, 13.4094214, accuracy: 0.00001)
        XCTAssertGreaterThan(route.count, 100)
    }

    func testNewYorkRunIsOneShortCounterclockwiseReservoirLap() throws {
        let entry = try XCTUnwrap(ExampleWorkoutData.entries.first {
            $0.id == NewYorkReservoirRoute.workoutID
        })
        let route = try XCTUnwrap(ExampleWorkoutData.route(for: entry.id))
        let first = try XCTUnwrap(route.first)
        let last = try XCTUnwrap(route.last)

        XCTAssertEqual(entry.displayName, "New York Run")
        XCTAssertEqual(entry.workoutType, .running)
        XCTAssertEqual(ExampleWorkoutData.entries.first?.id, entry.id)
        // Independent park-published distance: 1.58 miles / 2,543 meters.
        XCTAssertEqual(RouteGeometry.length(of: route), 2_543, accuracy: 25)
        XCTAssertEqual(try XCTUnwrap(entry.distance), RouteGeometry.length(of: route), accuracy: 0.01)
        XCTAssertLessThan(first.distance(from: last), 0.01)
        XCTAssertGreaterThan(route.count, 250)

        // Track bounds distinguish this lap from the wider bridle path and drives.
        for location in route {
            XCTAssertTrue((40.7819...40.7891).contains(location.coordinate.latitude))
            XCTAssertTrue((-73.9668 ... -73.9573).contains(location.coordinate.longitude))
        }
        // Positive signed area (east=x, north=y) is counterclockwise.
        // Translate to the start to avoid cancellation of large coordinates.
        let origin = first.coordinate
        let signedArea = zip(route, route.dropFirst()).reduce(0.0) { sum, pair in
            let a = pair.0.coordinate, b = pair.1.coordinate
            return sum + (a.longitude - origin.longitude) * (b.latitude - origin.latitude)
                - (b.longitude - origin.longitude) * (a.latitude - origin.latitude)
        }
        XCTAssertGreaterThan(signedArea, 0)
    }

    func testNewYorkReplayPreservesTrackBendsAndConsistentSpeed() throws {
        let entry = try XCTUnwrap(ExampleWorkoutData.entries.first {
            $0.id == NewYorkReservoirRoute.workoutID
        })
        let route = try XCTUnwrap(ExampleWorkoutData.route(for: entry.id))
        XCTAssertEqual(route.first?.timestamp, entry.startDate)
        XCTAssertEqual(route.last?.timestamp, entry.endDate)
        let expectedSpeed = try XCTUnwrap(entry.distance) / entry.duration
        for (a, b) in zip(route, route.dropFirst()) {
            let distance = a.distance(from: b)
            let interval = b.timestamp.timeIntervalSince(a.timestamp)
            XCTAssertGreaterThan(distance, 0)
            XCTAssertLessThanOrEqual(distance, 10.1)
            XCTAssertGreaterThan(interval, 0)
            XCTAssertEqual(distance / interval, expectedSpeed, accuracy: 0.001)
        }
        // Densification must retain each mapped bend, not replace it with a spline.
        for vertex in NewYorkReservoirRoute.waypoints {
            let location = CLLocation(latitude: vertex.latitude, longitude: vertex.longitude)
            XCTAssertTrue(route.contains { $0.distance(from: location) < 0.01 })
        }
    }

    func testElevationGainSumsPositiveDeltas() {
        let points = [
            CLLocation(coordinate: loc(40, -74).coordinate, altitude: 10, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date()),
            CLLocation(coordinate: loc(40.001, -74).coordinate, altitude: 14, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date()),
            CLLocation(coordinate: loc(40.002, -74).coordinate, altitude: 12, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date()),
            CLLocation(coordinate: loc(40.003, -74).coordinate, altitude: 20, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date()),
        ]
        XCTAssertEqual(WorkoutDetailView.elevationGain(for: points), 12, accuracy: 0.001) // 4 + 0 + 8
    }
}
