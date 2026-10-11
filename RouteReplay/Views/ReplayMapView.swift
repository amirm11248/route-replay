import SwiftUI
import MapKit

/// A camera command emitted by the replay engine every display tick.
///
/// The SwiftUI `Map(position:)` camera binding proved unreliable for
/// continuous follow-cameras (updates after the first render were silently
/// dropped), so the map is driven through an `MKMapView`, which applies camera
/// changes via `setCamera(_:animated:)` — the same path navigation apps use.
struct CameraCommand: Equatable {
    var centerCoordinate: CLLocationCoordinate2D
    var distance: Double
    var heading: Double
    var pitch: Double

    /// A zero camera that means "don't touch the camera" (used before replay
    /// starts, while the map is fitting the route).
    static let none = CameraCommand(
        centerCoordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        distance: 0,
        heading: 0,
        pitch: 0
    )

    static func == (lhs: CameraCommand, rhs: CameraCommand) -> Bool {
        lhs.centerCoordinate.latitude == rhs.centerCoordinate.latitude
            && lhs.centerCoordinate.longitude == rhs.centerCoordinate.longitude
            && lhs.distance == rhs.distance
            && lhs.heading == rhs.heading
            && lhs.pitch == rhs.pitch
    }
}

/// An `MKMapView` wrapper for the workout map.
///
/// - Detail mode: standard map fitted to the route, user can pan/zoom.
/// - Replay mode: 3D satellite flyover whose camera follows the rider, with
///   interaction disabled so nothing can fight the programmatic camera.
struct ReplayMapView: UIViewRepresentable {
    let route: [CLLocation]?
    let markerCoordinate: CLLocationCoordinate2D?
    let isReplayActive: Bool
    let camera: CameraCommand
    /// Bump to ask the map to fit the whole route (on load / after replay).
    let fitToken: Int
    /// Space reserved above app-owned bottom overlays so MapKit's built-in
    /// Apple Maps logo and Legal link remain visible and tappable.
    let attributionBottomInset: CGFloat
    /// Set by MapKit when tiles can't be fetched (e.g. offline); cleared again
    /// when the map finishes loading so the banner auto-recovers.
    @Binding var tileLoadFailed: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.isPitchEnabled = true
        context.coordinator.baseLayoutMargins = map.layoutMargins
        updateAttributionLayout(map, coordinator: context.coordinator)
        map.register(
            RouteMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: RouteMarkerAnnotationView.reuseID
        )
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        let coordinator = context.coordinator
        coordinator.tileLoadFailed = $tileLoadFailed
        updateAttributionLayout(map, coordinator: coordinator)

        // 1. Route polyline (rebuilt only when the route actually changes).
        if coordinator.loadedRouteKey != routeKey {
            coordinator.loadedRouteKey = routeKey
            coordinator.lastCommand = nil
            coordinator.lastMarkerCoordinate = nil
            map.removeOverlays(map.overlays)
            if let route, route.count > 1 {
                let coords = route.map(\.coordinate)
                map.addOverlay(MKPolyline(coordinates: coords, count: coords.count))
            }
        }

        // 2. The "You" marker (created once, coordinate updated each tick).
        let markerDidChange = !coordinator.coordinatesMatch(
            coordinator.lastMarkerCoordinate,
            markerCoordinate
        )
        if coordinator.marker == nil, let markerCoordinate {
            let marker = MKPointAnnotation()
            marker.title = "You"
            marker.coordinate = markerCoordinate
            map.addAnnotation(marker)
            coordinator.marker = marker
        } else if let marker = coordinator.marker {
            if let markerCoordinate {
                if marker.coordinate.latitude != markerCoordinate.latitude
                    || marker.coordinate.longitude != markerCoordinate.longitude {
                    marker.coordinate = markerCoordinate
                }
            } else {
                map.removeAnnotation(marker)
                coordinator.marker = nil
            }
        }
        if markerCoordinate == nil {
            coordinator.lastMarkerCoordinate = nil
        }

        // 3. Mode switch: map style + interaction. POIs and the compass stay
        // on the standard detail map, and are hidden only during the flyover.
        if coordinator.lastReplayActive != isReplayActive {
            coordinator.lastReplayActive = isReplayActive
            coordinator.lastCommand = nil
            coordinator.lastMarkerCoordinate = nil
            map.mapType = isReplayActive ? .satelliteFlyover : .standard
            map.isScrollEnabled = !isReplayActive
            map.isZoomEnabled = !isReplayActive
            map.isRotateEnabled = !isReplayActive
            map.isPitchEnabled = !isReplayActive
            map.showsCompass = !isReplayActive
            map.pointOfInterestFilter = isReplayActive ? .excludingAll : .includingAll
        }

        // 4. Camera: follow the route during replay, fit the route otherwise.
        //
        // The follow correction is applied here, after MapKit has the new
        // camera, because only the map view knows where the marker actually
        // lands on this device's screen at the current pitch and zoom.
        let commandDidChange = coordinator.lastCommand != camera
        if isReplayActive,
           camera != .none,
           (commandDidChange || markerDidChange) {
            coordinator.lastCommand = camera
            coordinator.applyFollowCamera(
                camera,
                to: map,
                markerCoordinate: markerCoordinate
            )
        } else if !isReplayActive, fitToken != coordinator.lastFitToken {
            coordinator.lastFitToken = fitToken
            if let route, route.count > 1 {
                map.setRegion(ReplayMapView.region(for: route), animated: true)
            }
        }
        coordinator.lastMarkerCoordinate = markerCoordinate
    }

    /// MapKit owns the Apple Maps logo and Legal link.  Keep their built-in
    /// placement inside a protected area above the app's moving bottom sheet
    /// and replay controls; never recreate, hide, or modify those notices.
    private func updateAttributionLayout(
        _ map: MKMapView,
        coordinator: Coordinator
    ) {
        let requestedBottom = max(0, attributionBottomInset)
        let base = coordinator.baseLayoutMargins ?? map.layoutMargins
        let margins = UIEdgeInsets(
            top: max(base.top, 10),
            left: max(base.left, 7),
            bottom: max(base.bottom, requestedBottom + 10),
            right: max(base.right, 7)
        )

        // MapKit can update its internal control layout after a map-type or
        // size change. Compare against the live value instead of only the
        // requested inset so the Apple Maps logo and Legal link are restored
        // whenever that happens.
        if map.layoutMargins != margins {
            map.layoutMargins = margins
        }
        coordinator.lastAttributionBottomInset = requestedBottom
    }

    // MARK: - Route identity

    /// Stable key for the loaded route (arrays have no stable identity, so key
    /// on endpoints + count — rebuilt only when the route actually changes).
    private var routeKey: String {
        guard let route,
              let first = route.first?.coordinate,
              let last = route.last?.coordinate else { return "" }
        return "\(route.count)-first(\(first.latitude),\(first.longitude))-last(\(last.latitude),\(last.longitude))"
    }

    /// Bounding region covering the whole route.
    static func region(for locations: [CLLocation]) -> MKCoordinateRegion {
        let coords = locations.map(\.coordinate)
        var minLat = coords[0].latitude, maxLat = coords[0].latitude
        var minLon = coords[0].longitude, maxLon = coords[0].longitude
        for c in coords.dropFirst() {
            minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
        }
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, 0.001) * 1.35,
            longitudeDelta: max(maxLon - minLon, 0.001) * 1.35
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        var marker: MKPointAnnotation?
        var loadedRouteKey: String?
        var lastReplayActive: Bool?
        var lastCommand: CameraCommand?
        var lastMarkerCoordinate: CLLocationCoordinate2D?
        var lastFitToken: Int?
        var tileLoadFailed: Binding<Bool>?
        var baseLayoutMargins: UIEdgeInsets?
        var lastAttributionBottomInset: CGFloat?

        /// Keep the rider below the screen midpoint, but inside the top half
        /// of the lower half. The inner landing points leave a little room for
        /// normal route-following movement instead of freezing the marker to a
        /// single screen coordinate.
        private enum FollowVerticalBand {
            static let minimumFraction: CGFloat = 0.50
            static let maximumFraction: CGFloat = 0.75
            static let upperLandingFraction: CGFloat = 0.56
            static let lowerLandingFraction: CGFloat = 0.69
        }

        /// Applies a camera target directly, then corrects only the vertical
        /// framing when the marker would leave the follow band. Applying the
        /// correction after `setCamera` makes it work consistently across
        /// pitch, zoom, orientation, and MapKit's perspective projection.
        func applyFollowCamera(
            _ command: CameraCommand,
            to map: MKMapView,
            markerCoordinate: CLLocationCoordinate2D?
        ) {
            let camera = MKMapCamera(
                lookingAtCenter: command.centerCoordinate,
                fromDistance: command.distance,
                pitch: command.pitch,
                heading: command.heading
            )

            // Apply each target directly. An animated setCamera would restart
            // MapKit's easing on every display tick and make the camera surge
            // and settle repeatedly instead of matching the replay clock.
            map.setCamera(camera, animated: false)

            guard let markerCoordinate,
                  map.bounds.width > 0,
                  map.bounds.height > 0 else { return }

            // Perspective can require a second pass, especially when the
            // user changes pitch or zoom while the replay is paused.
            for _ in 0..<2 {
                guard let correctedCenter = correctedCenter(
                    for: markerCoordinate,
                    in: map
                ) else { break }

                map.setCamera(
                    MKMapCamera(
                        lookingAtCenter: correctedCenter,
                        fromDistance: command.distance,
                        pitch: command.pitch,
                        heading: command.heading
                    ),
                    animated: false
                )
            }
        }

        /// Returns a new center only when the marker is outside the vertical
        /// sweet spot. The map's current projection supplies the geographic
        /// offset, so this remains correct with a pitched/rotated camera.
        private func correctedCenter(
            for markerCoordinate: CLLocationCoordinate2D,
            in map: MKMapView
        ) -> CLLocationCoordinate2D? {
            let bounds = map.bounds
            let markerPoint = map.convert(markerCoordinate, toPointTo: map)
            guard markerPoint.y.isFinite else { return nil }

            let minimumY = bounds.minY + bounds.height * FollowVerticalBand.minimumFraction
            let maximumY = bounds.minY + bounds.height * FollowVerticalBand.maximumFraction

            let landingFraction: CGFloat
            if markerPoint.y < minimumY {
                landingFraction = FollowVerticalBand.upperLandingFraction
            } else if markerPoint.y > maximumY {
                landingFraction = FollowVerticalBand.lowerLandingFraction
            } else {
                return nil
            }

            let targetPoint = CGPoint(
                x: markerPoint.x,
                y: bounds.minY + bounds.height * landingFraction
            )
            let targetCoordinate = map.convert(targetPoint, toCoordinateFrom: map)
            guard CLLocationCoordinate2DIsValid(targetCoordinate) else { return nil }

            // Translate the current camera center by the map-space vector
            // between the marker and the coordinate currently under the target
            // screen point. This moves the marker vertically while preserving
            // the camera's requested heading, pitch, and distance.
            let currentCenter = MKMapPoint(map.camera.centerCoordinate)
            let markerMapPoint = MKMapPoint(markerCoordinate)
            let targetMapPoint = MKMapPoint(targetCoordinate)
            let correctedMapPoint = MKMapPoint(
                x: currentCenter.x + markerMapPoint.x - targetMapPoint.x,
                y: currentCenter.y + markerMapPoint.y - targetMapPoint.y
            )
            let correctedCoordinate = correctedMapPoint.coordinate
            return CLLocationCoordinate2DIsValid(correctedCoordinate)
                ? correctedCoordinate
                : nil
        }

        func coordinatesMatch(
            _ lhs: CLLocationCoordinate2D?,
            _ rhs: CLLocationCoordinate2D?
        ) -> Bool {
            switch (lhs, rhs) {
            case (nil, nil):
                return true
            case let (left?, right?):
                return left.latitude == right.latitude
                    && left.longitude == right.longitude
            default:
                return false
            }
        }

        /// Uses the registered custom marker instead of MapKit's default pin.
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation), annotation is MKPointAnnotation else { return nil }
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: RouteMarkerAnnotationView.reuseID,
                for: annotation
            )
        }

        /// Tiles couldn't be fetched (offline, restricted network, …).
        func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
            tileLoadFailed?.wrappedValue = true
        }

        /// Tiles loaded (or finished loading) — clear the failure banner.
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            tileLoadFailed?.wrappedValue = false
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

/// The "You" marker: a white dot with a blue ring, matching the app's design.
final class RouteMarkerAnnotationView: MKAnnotationView {
    static let reuseID = "routeMarker"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = Self.markerImage
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static let markerImage: UIImage = {
        let size = CGSize(width: 44, height: 44)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            // Soft shadow.
            ctx.cgContext.setShadow(
                offset: CGSize(width: 0, height: 2),
                blur: 4,
                color: UIColor.black.withAlphaComponent(0.4).cgColor
            )

            // White fill.
            UIColor.white.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 10, y: 8, width: 24, height: 24))

            // Blue ring.
            UIColor.systemBlue.setStroke()
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.strokeEllipse(in: CGRect(x: 10, y: 8, width: 24, height: 24))
            _ = center
        }
    }()
}
