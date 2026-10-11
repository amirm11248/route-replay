import Foundation
import CoreLocation

/// Distance-based helpers for route resampling, positions and bearings.
enum RouteGeometry {

    /// Removes malformed points before route metrics or map rendering use
    /// them. HealthKit can occasionally contain an invalid fix while a watch
    /// is acquiring GPS; one bad point should not make the whole workout look
    /// like a usable route.
    static func cleanedGPSLocations(_ locations: [CLLocation]) -> [CLLocation] {
        locations.filter { location in
            let coordinate = location.coordinate
            return coordinate.latitude.isFinite
                && coordinate.longitude.isFinite
                && (-90...90).contains(coordinate.latitude)
                && (-180...180).contains(coordinate.longitude)
                && location.horizontalAccuracy >= 0
        }
    }

    /// A route is only considered real GPS data when it contains multiple
    /// valid fixes separated by a meaningful distance. This excludes indoor
    /// and strength workouts (which commonly have no route series) as well as
    /// empty/two-point placeholder series.
    static func hasUsableGPSData(_ locations: [CLLocation], minimumDistance: Double = 25) -> Bool {
        let cleaned = cleanedGPSLocations(locations)
        return cleaned.count > 1 && length(of: cleaned) >= minimumDistance
    }

    static func length(of locations: [CLLocation]) -> Double {
        var total = 0.0
        for (a, b) in zip(locations, locations.dropFirst()) {
            total += a.distance(from: b)
        }
        return total
    }

    /// Resamples the route into evenly spaced points (~`spacing` meters apart)
    /// so camera stepping stays smooth regardless of raw GPS density.
    static func resample(_ locations: [CLLocation], spacing: Double) -> [CLLocationCoordinate2D] {
        guard locations.count > 1 else {
            return locations.map(\.coordinate)
        }

        var result: [CLLocationCoordinate2D] = [locations[0].coordinate]
        var carried = 0.0

        for (a, b) in zip(locations, locations.dropFirst()) {
            let segment = a.distance(from: b)
            guard segment > 0 else { continue }

            var remaining = segment + carried
            while remaining >= spacing {
                let t = 1 - remaining / segment
                let lat = a.coordinate.latitude + (b.coordinate.latitude - a.coordinate.latitude) * t
                let lon = a.coordinate.longitude + (b.coordinate.longitude - a.coordinate.longitude) * t
                result.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                remaining -= spacing
            }
            carried = remaining
        }

        result.append(locations[locations.count - 1].coordinate)
        return result
    }

    /// Returns the interpolated coordinate (and its raw altitude) at a given
    /// distance along the route.
    static func position(at meters: Double, along locations: [CLLocation]) -> (coordinate: CLLocationCoordinate2D, altitude: Double) {
        guard locations.count > 1 else {
            return (locations.first?.coordinate ?? CLLocationCoordinate2D(), locations.first?.altitude ?? 0)
        }
        var covered = 0.0
        for (a, b) in zip(locations, locations.dropFirst()) {
            let segment = a.distance(from: b)
            if covered + segment >= meters {
                let t = segment > 0 ? (meters - covered) / segment : 0
                let lat = a.coordinate.latitude + (b.coordinate.latitude - a.coordinate.latitude) * t
                let lon = a.coordinate.longitude + (b.coordinate.longitude - a.coordinate.longitude) * t
                let altitude = a.altitude + (b.altitude - a.altitude) * t
                return (CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude)
            }
            covered += segment
        }
        let last = locations[locations.count - 1]
        return (last.coordinate, last.altitude)
    }

    /// Center for the follow camera at a distance along the route: ~1.5s of
    /// travel ahead of the rider (scaled by speed), clamped to ~40% of the
    /// camera distance so the rider stays framed even at close zoom, and to
    /// the route length.
    static func followCameraCenter(
        at meters: Double,
        pace: Double,
        speed: Double,
        distance: Double,
        routeMeters: Double,
        route: [CLLocation]
    ) -> CLLocationCoordinate2D {
        let lead = min(
            meters + pace * speed * 1.5,
            meters + distance * 0.4,
            routeMeters
        )
        return position(at: lead, along: route).coordinate
    }

    static func bearing(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
        let lat1 = a.latitude * .pi / 180
        let lat2 = b.latitude * .pi / 180
        let dLon = (b.longitude - a.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    /// Signed shortest-arc difference from one heading to another.
    static func headingDelta(from current: Double, to target: Double) -> Double {
        var delta = (target - current).truncatingRemainder(dividingBy: 360)
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return delta
    }

    /// Blends the camera heading toward its target along the shortest arc so
    /// the view never snaps. The blend can be reduced for lower-motion modes;
    /// callers running at a different cadence should adjust the blend for
    /// elapsed time.
    static func smoothHeading(current: Double, target: Double, blend: Double = 0.22) -> Double {
        let delta = headingDelta(from: current, to: target)
        let clampedBlend = min(max(blend, 0), 1)
        return (current + delta * clampedBlend + 360).truncatingRemainder(dividingBy: 360)
    }
}
