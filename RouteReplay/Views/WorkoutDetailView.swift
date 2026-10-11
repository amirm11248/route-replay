import SwiftUI
import MapKit
import HealthKit
import QuartzCore

/// Detail screen for a single workout.
///
/// The detail screen has a draggable stats sheet. Tapping play hides the
/// sheet and switches to the 3D satellite flyover with a speed slider
/// (0.5×–10×), a bottom timeline, and zoom/3D-depth sliders (1–10,
/// revealed by the settings button).
struct WorkoutDetailView: View {
    let entry: WorkoutEntry

    @EnvironmentObject private var health: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var replayFooterClearance: CGFloat = 94

    // MARK: - Card detents

    private enum Detent: CGFloat, CaseIterable {
        case full = 0.80
        case half = 0.55
        case peek = 0.15
        case collapsed = 0.0
    }

    @State private var detent: Detent = .full
    @State private var cardDrag: CGFloat = 0

    // MARK: - Playback

    /// Replay chrome is active (satellite map, controls, marker, timeline).
    @State private var isReplayActive = false
    /// Camera is stepping along the route.
    @State private var isPlaying = false
    /// Replay speed multiplier (0.5×…10×), set by the speed slider.
    @State private var speed: Double = 1
    /// Zoom level 1–10 (mapped to camera distance).
    @State private var zoomLevel: Double = 3
    /// 3D-depth level 1–10 (mapped to camera pitch).
    @State private var depthLevel: Double = 7
    @State private var showingSpeedPanel = false
    @State private var showingCameraControls = false
    @State private var controlsExpanded = false
    @State private var controlsIntroductionPending = false
    @State private var replayChromeHeight: CGFloat = 290
    @State private var traveledMeters = 0.0
    @State private var lastHeading = 0.0
    @State private var markerCoordinate: CLLocationCoordinate2D?
    /// Camera target fed to the MKMapView-based map every tick.
    @State private var cameraCommand = CameraCommand.none
    /// Bumped to ask the map to refit the route (after load / after replay).
    @State private var fitToken = 0
    /// Cached resampled route points (computed once when playback starts).
    @State private var sampledRoute: [CLLocationCoordinate2D] = []
    /// True while the user is dragging the timeline scrubber.
    @State private var isScrubbing = false

    // MARK: - Data

    @State private var route: [CLLocation]?
    @State private var isLoadingRoute = false
    @State private var heartRateSamples: [HKQuantitySample] = []

    // MARK: - Map state

    /// True when MapKit reports it can't fetch map tiles (offline, restricted
    /// network) — shows a banner over the map until tiles load again.
    @State private var tileLoadFailed = false

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let isLandscape = geo.size.width > geo.size.height
            // In landscape the card scrolls through its content at full height;
            // a chevron replaces the drag-to-collapse gesture there.
            let cardScrollable = detent == .full || dynamicTypeSize.isAccessibilitySize
            ZStack(alignment: .bottom) {
                map(height: h)
                    .ignoresSafeArea()

                topArea

                if isReplayActive {
                    bottomBar
                } else {
                    cardContent(scrollable: cardScrollable)
                        .frame(width: geo.size.width, height: cardScrollable ? detentHeight(detent, height: h) : fullCardHeight(h), alignment: .top)
                        .frame(height: fullCardHeight(h), alignment: .top)
                        .offset(y: effectiveCardOffset(height: h))
                        .gesture(cardDragGesture(height: h), isEnabled: !cardScrollable)
                        .overlay(alignment: .topTrailing) {
                            if isLandscape && cardScrollable {
                                collapseCardButton
                            }
                        }
                        .ignoresSafeArea(edges: .bottom)
                }

                if !isReplayActive && !isCollapsed {
                    replayFooter
                }
            }
            .onAppear {
                if !isLandscape && !isReplayActive { detent = .half }
            }
            .onChange(of: isLandscape) { _, landscape in
                if !isReplayActive { detent = landscape ? .full : .half }
            }
        }
        .task { await loadData() }
        .task(id: isPlaying) {
            guard isPlaying else { return }
            if traveledMeters == 0 {
                prepareInitialCamera()
                markerCoordinate = sampledRoute.first
            }
            await runPlayback()
        }
        .task(id: isReplayActive) {
            guard isReplayActive else { return }
            do {
                try await Task.sleep(for: .seconds(3))
            } catch { return }
            guard !Task.isCancelled, isReplayActive, controlsIntroductionPending,
                  !UIAccessibility.isVoiceOverRunning else { return }
            withAnimation(controlsAnimation) { controlsExpanded = false }
            controlsIntroductionPending = false
        }
        .sensoryFeedback(.impact(weight: .light), trigger: detent)
        .sensoryFeedback(.impact(weight: .medium), trigger: isPlaying)
        .sensoryFeedback(.selection, trigger: speed)
        .onChange(of: zoomLevel) { _, _ in refreshCamera() }
        .onChange(of: depthLevel) { _, _ in refreshCamera() }
    }

    // MARK: - Camera mapping (levels 1–10)

    private var cameraDistance: Double {
        120 + (zoomLevel - 1) / 9 * (1200 - 120)
    }

    private var cameraPitch: Double {
        25 + (depthLevel - 1) / 9 * (80 - 25)
    }

    // MARK: - Back navigation

    private var topArea: some View {
        VStack {
            HStack {
                circleButton(icon: "chevron.left", foreground: AppTheme.primary, background: AnyShapeStyle(AppTheme.surface)) {
                    if isReplayActive { stopReplay() } else { dismiss() }
                }
                .accessibilityIdentifier("replay-close-button")
                .accessibilityLabel(isReplayActive ? "Back to workout" : "Back to workouts")
                Spacer()
                if !isReplayActive, let route, route.count > 1, isCollapsed {
                    playButton
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    /// Used only when the summary is collapsed; otherwise the primary action
    /// is anchored at the bottom of the visible neutral sheet.
    private var playButton: some View {
        Button { startReplay() } label: {
            Image(systemName: "play.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.actionForeground)
                .frame(width: 50, height: 50)
                .background(AppTheme.actionBackground, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Replay Route")
        .accessibilityIdentifier("replay-play-button")
    }

    @ViewBuilder
    private var replayFooter: some View {
        if let route, route.count > 1 {
            VStack(spacing: 9) {
                Button { startReplay() } label: {
                    Label("Replay Route", systemImage: "play.fill")
                }
                .buttonStyle(ReplayActionButtonStyle())
                .accessibilityIdentifier("replay-play-button")
                Text(health.isUsingExampleWorkouts ? "Example workout" : "Apple Watch workout")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondary)
                if entry.id == NewYorkReservoirRoute.workoutID {
                    Text("\(NewYorkReservoirRoute.name) · Counterclockwise")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondary)
                    Link("© OpenStreetMap contributors", destination: NewYorkReservoirRoute.attributionURL)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.secondary)
                        .accessibilityIdentifier("route-source-attribution")
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
            .background(AppTheme.background)
        }
    }

    private var speedPanel: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Replay speed")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(speedLabel).font(.subheadline.weight(.semibold)).monospacedDigit()
                panelCloseButton(identifier: "replay-speed-panel-close")
            }
            .foregroundStyle(AppTheme.primary)
            Slider(value: $speed, in: 0.5...10, step: 0.5)
                .accessibilityIdentifier("replay-speed-slider")
                .accessibilityLabel("Replay speed")
                .accessibilityValue(speedLabel)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            ReplayMatteMaterial().clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .shadow(color: AppTheme.shadow.opacity(0.10), radius: 10, y: 4)
        .frame(maxWidth: 260)
    }

    // MARK: - Camera controls (zoom + 3D depth), shown via the settings button

    private var cameraControls: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Camera").font(.subheadline.weight(.semibold))
                Spacer()
                panelCloseButton(identifier: "replay-camera-panel-close")
            }
            .foregroundStyle(AppTheme.primary)
            sliderRow(
                startIcon: "magnifyingglass.minus",
                endIcon: "magnifyingglass.plus",
                value: $zoomLevel,
                identifier: "replay-zoom-slider"
            )
            sliderRow(
                startIcon: "rectangle.landscape",
                endIcon: "view.3d",
                value: $depthLevel,
                identifier: "replay-pitch-slider"
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            ReplayMatteMaterial().clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .shadow(color: AppTheme.shadow.opacity(0.10), radius: 10, y: 4)
        .frame(maxWidth: 300)
        .frame(maxWidth: .infinity)
    }

    private func sliderRow(
        startIcon: String,
        endIcon: String,
        value: Binding<Double>,
        identifier: String
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: startIcon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
            Slider(value: value, in: 1...10, step: 1)
                .accessibilityIdentifier(identifier)
                .accessibilityLabel(identifier == "replay-zoom-slider" ? "Camera zoom" : "3D depth")
            Text("\(Int(value.wrappedValue.rounded()))")
                .font(.system(size: 14, weight: .bold, design: .default))
                .monospacedDigit()
                .foregroundStyle(AppTheme.primary)
                .frame(width: 22, alignment: .trailing)
            Image(systemName: endIcon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
        }
    }

    // MARK: - Bottom timeline (scrubbable)

    private var bottomBar: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if showingSpeedPanel {
                speedPanel
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .transition(.opacity)
            } else if showingCameraControls {
                cameraControls
                    .transition(.opacity)
            }

            GooeyAddMenu(
                expanded: controlsExpanded,
                isPlaying: isPlaying,
                speedLabel: speedLabel,
                onToggle: toggleReplayControls,
                onPlayback: { useReplayControl { isPlaying.toggle() } },
                onSpeed: {
                    useReplayControl {
                        showingSpeedPanel.toggle()
                        showingCameraControls = false
                    }
                },
                onCamera: {
                    useReplayControl {
                        showingCameraControls.toggle()
                        showingSpeedPanel = false
                    }
                }
            )
            .frame(maxWidth: .infinity, alignment: .trailing)

            timelineView
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
        .background {
            GeometryReader { geometry in
                Color.clear.preference(key: ReplayChromeHeightKey.self, value: geometry.size.height)
            }
        }
        .onPreferenceChange(ReplayChromeHeightKey.self) { height in
            if abs(replayChromeHeight - height) > 0.5 { replayChromeHeight = height }
        }
    }

    private var timelineView: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 0) {
                    timelineSlider
                    HStack {
                        Text(Self.timeText(elapsed))
                        Spacer()
                        Text(Self.timeText(entry.duration))
                    }
                }
            } else {
                HStack(spacing: 10) {
                    Text(Self.timeText(elapsed)).fixedSize()
                    timelineSlider
                    Text(Self.timeText(entry.duration)).fixedSize()
                }
            }
        }
        .font(.caption2.weight(.semibold))
        .monospacedDigit()
        .foregroundStyle(AppTheme.primary)
        .frame(minHeight: 44)
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background {
            ReplayMatteMaterial()
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(AppTheme.primary.opacity(0.10), lineWidth: 0.5))
        }
        .shadow(color: AppTheme.shadow.opacity(0.08), radius: 8, y: 3)
    }

    private var timelineSlider: some View {
        Slider(value: scrubBinding, in: 0...1, onEditingChanged: { isScrubbing = $0 })
            .tint(AppTheme.accent)
            .frame(minWidth: 80, minHeight: 44)
            .accessibilityIdentifier("replay-scrub-slider")
            .accessibilityLabel("Route progress")
            .accessibilityValue(progressFraction.formatted(.percent.precision(.fractionLength(0))))
    }

    private var controlsAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.78)
    }

    private func toggleReplayControls() {
        controlsIntroductionPending = false
        withAnimation(controlsAnimation) {
            controlsExpanded.toggle()
            showingSpeedPanel = false
            showingCameraControls = false
        }
    }

    private func useReplayControl(_ action: () -> Void) {
        controlsIntroductionPending = false
        withAnimation(controlsAnimation) {
            controlsExpanded = false
            action()
        }
    }

    private func panelCloseButton(identifier: String) -> some View {
        Button {
            withAnimation(controlsAnimation) {
                showingSpeedPanel = false
                showingCameraControls = false
            }
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close controls panel")
        .accessibilityIdentifier(identifier)
    }

    // MARK: - Draggable card

    /// Opaque neutral surfaces keep the chosen palette independent of map imagery.
    private var adaptiveCardFill: AnyShapeStyle {
        AnyShapeStyle(AppTheme.background)
    }

    private func cardContent(scrollable: Bool) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                WorkoutStatsCard(
                    entry: entry,
                    heartRateSamples: heartRateSamples,
                    elevationGain: elevationGain,
                    expanded: detent == .full,
                    compact: detent == .peek,
                    onToggleDetails: {
                        withAnimation(snapAnimation) { detent = detent == .full ? .half : .full }
                    }
                )
                .padding(.bottom, replayFooterClearance)
            }
            .frame(maxWidth: .infinity)
        }
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 26, topTrailingRadius: 26, style: .continuous)
                .fill(adaptiveCardFill)
                .shadow(color: AppTheme.shadow.opacity(0.12), radius: 20, y: -4)
        }
        .scrollDisabled(!scrollable)
        .accessibilityIdentifier("workout-summary-panel")
    }

    /// Landscape-only affordance: at full height the card is scrollable, so a
    /// chevron replaces the drag-to-collapse gesture.
    private var collapseCardButton: some View {
        Button {
            withAnimation(snapAnimation) { detent = .half }
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppTheme.secondary)
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(adaptiveCardFill)
                        .overlay(Circle().stroke(Color.secondary.opacity(0.35), lineWidth: 1))
                }
        }
        .buttonStyle(.plain)
        .padding(.trailing, 14)
        .padding(.top, 10)
        .accessibilityLabel("Collapse card")
        .accessibilityIdentifier("card-collapse-button")
    }

    // MARK: - Map

    /// Protect MapKit's Apple Maps logo and Legal link above the detail sheet
    /// or the replay timeline. Replay has no workout summary overlay.
    private func mapAttributionBottomInset(height h: CGFloat) -> CGFloat {
        if isReplayActive { return max(112, replayChromeHeight + 16) }
        return max(0, fullCardHeight(h) - effectiveCardOffset(height: h))
    }

    private func map(height h: CGFloat) -> some View {
        ZStack {
            ReplayMapView(
                route: route,
                markerCoordinate: isReplayActive ? markerCoordinate : nil,
                isReplayActive: isReplayActive,
                camera: cameraCommand,
                fitToken: fitToken,
                attributionBottomInset: mapAttributionBottomInset(height: h),
                tileLoadFailed: $tileLoadFailed
            )
            .allowsHitTesting(!isLoadingRoute)

            if isLoadingRoute && route == nil {
                ProgressView("Loading route…")
                    .font(.system(.body, design: .default))
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if route == nil && !isLoadingRoute {
                noRouteBanner
            }

            if tileLoadFailed {
                mapUnavailableBanner
            }
        }
        .onChange(of: route) { _, newValue in
            guard let newValue, newValue.count > 1, !isPlaying else { return }
            fitToken += 1
        }
    }

    private var noRouteBanner: some View {
        VStack(spacing: 10) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
            Text("No GPS route recorded for this workout")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundStyle(AppTheme.secondary)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// Shown when MapKit reports it can't fetch map tiles (e.g. offline).
    /// Playback still works — only the imagery is missing — so this explains
    /// the blank map instead of leaving the user staring at an empty grid.
    private var mapUnavailableBanner: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
            Text("Map imagery isn't loading")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundStyle(AppTheme.primary)
            Text("The map tiles come from Apple Maps — check your internet connection. The flyover and route still work without them.")
                .font(.system(size: 13, design: .default))
                .foregroundStyle(AppTheme.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 36)
        .allowsHitTesting(false)
    }

    private func circleButton(
        icon: String,
        foreground: Color,
        background: AnyShapeStyle,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: 44, height: 44)
                .background(background, in: Circle())
                .overlay(Circle().stroke(AppTheme.line, lineWidth: 1))
                .shadow(color: AppTheme.shadow.opacity(0.12), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Card geometry & drag physics

    private var isCollapsed: Bool { detent == .collapsed }

    /// Keep enough map visible in landscape for MapKit's built-in attribution
    /// controls. The card remains scrollable, so this only changes its outer
    /// frame in the compact-height layout.
    private func fullCardFraction(_ h: CGFloat) -> CGFloat {
        h < 500 ? 0.65 : Detent.full.rawValue
    }

    private func fullCardHeight(_ h: CGFloat) -> CGFloat {
        h * fullCardFraction(h)
    }

    private func detentHeight(_ detent: Detent, height h: CGFloat) -> CGFloat {
        detent == .full ? fullCardHeight(h) : h * detent.rawValue
    }

    private func baseCardOffset(_ detent: Detent, height h: CGFloat) -> CGFloat {
        fullCardHeight(h) - detentHeight(detent, height: h)
    }

    /// Where the card sits right now: the detent's base offset plus the live
    /// drag, rubber-banded beyond the edges so the card resists instead of
    /// stopping hard. The bottom limit is the fully-hidden (collapsed) spot.
    private func effectiveCardOffset(height h: CGFloat) -> CGFloat {
        let raw = baseCardOffset(detent, height: h) + cardDrag
        if raw < 0 {
            return raw * 0.3
        }
        let maxOffset = fullCardHeight(h)
        if raw > maxOffset {
            return maxOffset + (raw - maxOffset) * 0.3
        }
        return raw
    }

    private var snapAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.2)
            : .interactiveSpring(response: 0.3, dampingFraction: 0.8)
    }

    private func cardDragGesture(height h: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                cardDrag = value.translation.height
            }
            .onEnded { value in
                // Momentum projection: aim at the detent nearest where the
                // finger was headed (including fully collapsed), then spring.
                let projected = baseCardOffset(detent, height: h) + value.predictedEndTranslation.height
                let clamped = min(max(projected, 0), fullCardHeight(h))
                let target = Detent.allCases.min { a, b in
                    abs(baseCardOffset(a, height: h) - clamped) < abs(baseCardOffset(b, height: h) - clamped)
                } ?? .full
                withAnimation(snapAnimation) {
                    cardDrag = 0
                    detent = target
                }
            }
    }

    // MARK: - Playback engine

    private var routeMeters: Double {
        RouteGeometry.length(of: route ?? [])
    }

    private var speedMultiplier: Double { speed }

    private var realTimePace: Double {
        guard entry.duration > 0 else { return 2.5 }
        return routeMeters / entry.duration
    }

    /// The flyover glides at least this fast so slow workouts (a 10-minute
    /// stroll-pace ride) still read as a living 3D journey instead of
    /// imperceptible motion. The speed slider scales on top of this.
    private static let minCinematicPace: Double = 10.0

    /// Pace actually used for the camera (real pace, floored to stay visible).
    /// Under reduced motion the floor is gentler so the glide stays calm.
    private var playbackPace: Double {
        max(realTimePace, reduceMotion ? 4.0 : Self.minCinematicPace)
    }

    private var elapsed: TimeInterval {
        entry.duration * (traveledMeters / max(routeMeters, 1))
    }

    private var progressFraction: Double {
        routeMeters > 0 ? min(traveledMeters / routeMeters, 1) : 0
    }

    private var speedLabel: String {
        String(format: "%g×", speed)
    }

    private var scrubBinding: Binding<Double> {
        Binding(
            get: { progressFraction },
            set: { scrub(to: $0) }
        )
    }

    /// Jumps playback (marker + camera) to a fraction of the route.
    private func scrub(to fraction: Double) {
        let clamped = min(max(fraction, 0), 1)
        traveledMeters = clamped * routeMeters
        guard let route, route.count > 1, isReplayActive else { return }
        let position = RouteGeometry.position(at: traveledMeters, along: route)
        markerCoordinate = position.coordinate
        let center = RouteGeometry.followCameraCenter(
            at: traveledMeters,
            pace: playbackPace,
            speed: speedMultiplier,
            distance: cameraDistance,
            routeMeters: routeMeters,
            route: route
        )
        lastHeading = RouteGeometry.bearing(from: position.coordinate, to: center)
        cameraCommand = makeCameraCommand(at: traveledMeters)
    }

    private func startReplay() {
        guard let route, route.count > 1, routeMeters > 0 else { return }
        sampledRoute = RouteGeometry.resample(route, spacing: 4)
        traveledMeters = 0
        isScrubbing = false
        controlsExpanded = true
        controlsIntroductionPending = true
        showingSpeedPanel = false
        showingCameraControls = false
        replayChromeHeight = 290
        withAnimation(snapAnimation) {
            isReplayActive = true
        }
        isPlaying = true
    }

    private func stopReplay() {
        isPlaying = false
        traveledMeters = 0
        markerCoordinate = nil
        cameraCommand = .none
        fitToken += 1
        showingSpeedPanel = false
        showingCameraControls = false
        controlsExpanded = false
        controlsIntroductionPending = false
        isScrubbing = false
        withAnimation(snapAnimation) {
            detent = .half
            isReplayActive = false
        }
    }

    private func prepareInitialCamera() {
        guard let route, route.count > 1 else { return }
        let start = route[0].coordinate
        let center = RouteGeometry.followCameraCenter(
            at: 0,
            pace: playbackPace,
            speed: speedMultiplier,
            distance: cameraDistance,
            routeMeters: routeMeters,
            route: route
        )
        let heading = RouteGeometry.bearing(from: start, to: center)
        lastHeading = heading
        cameraCommand = CameraCommand(
            centerCoordinate: center,
            distance: cameraDistance,
            heading: heading,
            pitch: cameraPitch
        )
    }

    /// Builds the follow-camera command at a given distance along the route
    /// using the current zoom, pitch and (already-smoothed) heading.
    private func makeCameraCommand(at meters: Double) -> CameraCommand {
        guard let route, route.count > 1 else { return .none }
        let center = RouteGeometry.followCameraCenter(
            at: meters,
            pace: playbackPace,
            speed: speedMultiplier,
            distance: cameraDistance,
            routeMeters: routeMeters,
            route: route
        )
        return CameraCommand(
            centerCoordinate: center,
            distance: cameraDistance,
            heading: lastHeading,
            pitch: cameraPitch
        )
    }

    /// Re-applies the current camera with the latest zoom/pitch settings.
    /// Used by the slider handlers so changes take effect immediately, even
    /// when playback is paused.
    private func refreshCamera() {
        guard isReplayActive else { return }
        cameraCommand = makeCameraCommand(at: traveledMeters)
    }

    private func runPlayback() async {
        // The first camera is prepared synchronously when play is tapped; do
        // not add a half-second of dead time before the replay starts.
        await Task.yield()

        // Use a monotonic clock so the route advances by elapsed time rather
        // than by a fixed distance per sleep. Task scheduling and rendering
        // can vary, but the replay speed should not.
        var lastTick = CACurrentMediaTime()

        while !Task.isCancelled {
            guard isPlaying else { break }

            // Hands off while the user drags the timeline scrubber.
            if isScrubbing {
                lastTick = CACurrentMediaTime()
                try? await Task.sleep(for: .milliseconds(16))
                continue
            }

            let now = CACurrentMediaTime()
            let elapsedSinceLastTick = max(0, now - lastTick)
            lastTick = now
            traveledMeters += playbackPace * speedMultiplier * elapsedSinceLastTick

            if traveledMeters >= routeMeters {
                traveledMeters = 0 // loop
                prepareInitialCamera()
            }

            guard let route, route.count > 1 else { continue }
            let points = sampledRoute
            guard points.count > 1 else { continue }

            let position = RouteGeometry.position(at: traveledMeters, along: route)
            markerCoordinate = position.coordinate

            // Preview curves early and keep heading changes gradual while the
            // camera center continues to advance every display tick.
            let cameraCenter = RouteGeometry.followCameraCenter(
                at: traveledMeters,
                pace: playbackPace,
                speed: speedMultiplier,
                distance: cameraDistance,
                routeMeters: routeMeters,
                route: route
            )
            let targetHeading = RouteGeometry.bearing(from: position.coordinate, to: cameraCenter)
            let headingDelta = abs(RouteGeometry.headingDelta(from: lastHeading, to: targetHeading))
            if headingDelta >= 2.5 {
                lastHeading = RouteGeometry.smoothHeading(
                    current: lastHeading,
                    target: targetHeading,
                    blend: reduceMotion ? 0.10 : 0.14
                )
            }

            cameraCommand = makeCameraCommand(at: traveledMeters)

            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    // MARK: - Data

    private var elevationGain: Double? {
        route.map(Self.elevationGain) ?? entry.elevationGain
    }

    private func loadData() async {
        guard route == nil && !isLoadingRoute else { return }
        isLoadingRoute = true
        defer { isLoadingRoute = false }

        async let locations = health.routeLocations(for: entry.id)
        async let hr = health.heartRateSamples(for: entry.id)

        let (routeLocations, hrSamples) = await (locations, hr)
        route = routeLocations
        heartRateSamples = hrSamples

        #if DEBUG
        // UI-test hooks: render with a bundled route when HealthKit has no
        // route data (permission sheet pending). Never affect release builds.
        if route == nil, ProcessInfo.processInfo.environment["AUTOSEED_DETAIL"] == "1" {
            route = MockData.route
        }
        if ProcessInfo.processInfo.environment["AUTOSEED_PLAY"] == "1", route != nil, !isPlaying {
            startReplay()
        }
        #endif
    }

    // MARK: - Geometry helpers

    /// Sum of positive altitude changes along the route (elevation gained).
    static func elevationGain(for locations: [CLLocation]) -> Double {
        var gain = 0.0
        var previous: Double?
        for location in locations where location.verticalAccuracy >= 0 {
            if let previous, location.altitude > previous {
                gain += location.altitude - previous
            }
            previous = location.altitude
        }
        return gain
    }

    private static func timeText(_ interval: TimeInterval) -> String {
        let total = Int(interval.rounded())
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}
