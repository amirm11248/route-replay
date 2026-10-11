import XCTest

/// Drives the app end-to-end on the simulator: permission screen → local
/// example workout list → detail → 3D satellite replay. Each step attaches a
/// screenshot to the test results for visual review.
final class WorkoutFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPermissionScreen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-RESET_ROUTE_REPLAY_SOURCE"]
        app.launch()

        let connectButton = app.buttons["Allow & Sync Workouts"]
        XCTAssertTrue(connectButton.waitForExistence(timeout: 10), "Connect button should appear")
        let examplesButton = app.buttons["test-example-workouts-button"]
        XCTAssertTrue(examplesButton.waitForExistence(timeout: 5), "Example-workout test path should be available")
        attachScreenshot(named: "01-permission")
    }

    /// The named New York sample is discoverable and opens its attributed route.
    func testNewYorkExampleRun() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-RESET_ROUTE_REPLAY_SOURCE"]
        app.launchEnvironment["AUTOSEED"] = "1"
        app.launch()

        let row = app.buttons.matching(identifier: "workout-row").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        XCTAssertTrue(row.label.contains("New York Run"))
        row.tap()
        XCTAssertTrue(app.buttons["replay-play-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["New York Run"].exists)
        XCTAssertTrue(app.staticTexts["Central Park Reservoir · Counterclockwise"].exists)
        XCTAssertTrue(app.links["route-source-attribution"].exists)
        attachScreenshot(named: "new-york-reservoir-detail")

        app.buttons["replay-play-button"].tap()
        XCTAssertTrue(app.sliders["replay-scrub-slider"].waitForExistence(timeout: 10))
        attachScreenshot(named: "new-york-reservoir-replay")
        app.buttons["replay-close-button"].tap()
        XCTAssertTrue(app.buttons["replay-play-button"].waitForExistence(timeout: 5))
    }

    /// Appearance is persisted across launches and reaches the presented detail
    /// and replay screens. Expanded statistics stay accessible from the summary.
    func testAppearanceAndExpandedDetails() throws {
        let app = XCUIApplication()
        app.launchEnvironment["AUTOSEED"] = "1"
        app.launch()

        let settings = app.buttons["settings-button"]
        XCTAssertTrue(settings.waitForExistence(timeout: 15))
        settings.tap()
        let appearance = app.segmentedControls["appearance-picker"]
        XCTAssertTrue(appearance.waitForExistence(timeout: 5))
        appearance.buttons["Dark"].tap()
        XCTAssertTrue(appearance.buttons["Dark"].isSelected)
        app.buttons["Done"].tap()

        app.buttons.matching(identifier: "workout-row").firstMatch.tap()
        let play = app.buttons["replay-play-button"]
        XCTAssertTrue(play.waitForExistence(timeout: 10))
        attachScreenshot(named: "onyx-detail")
        play.tap()
        showReplayControls(in: app)
        attachScreenshot(named: "onyx-replay-fan")
        let pause = app.buttons["replay-pause-button"]
        XCTAssertTrue(pause.waitForExistence(timeout: 5))
        pause.tap()
        attachScreenshot(named: "onyx-replay")
        app.buttons["replay-close-button"].tap()
        app.buttons["replay-close-button"].tap()

        app.terminate()
        app.launch()
        XCTAssertTrue(settings.waitForExistence(timeout: 10))
        settings.tap()
        XCTAssertTrue(appearance.waitForExistence(timeout: 5))
        XCTAssertTrue(appearance.buttons["Dark"].isSelected, "Appearance should survive relaunch")
        appearance.buttons["Light"].tap()
        XCTAssertTrue(appearance.buttons["Light"].isSelected)
        app.buttons["Done"].tap()

        app.buttons.matching(identifier: "workout-row").firstMatch.tap()
        XCTAssertTrue(play.waitForExistence(timeout: 10))
        attachScreenshot(named: "platinum-detail")
        let moreDetails = app.buttons["workout-more-details-button"]
        moreDetails.tap()
        XCTAssertTrue(app.staticTexts["Active Energy"].waitForExistence(timeout: 5))
        attachScreenshot(named: "platinum-expanded-details")
        moreDetails.tap()
        XCTAssertEqual(moreDetails.label, "More Detail")
    }

    /// Example mode is local-only, survives a relaunch, and keeps the real
    /// HealthKit sync action available from Settings.
    func testExampleModePersistenceAndHealthSyncSetting() throws {
        let app = XCUIApplication()
        app.launchEnvironment["AUTOSEED"] = "1"
        app.launch()

        let firstRow = app.buttons.matching(identifier: "workout-row").firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 15))

        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons.matching(identifier: "workout-row").firstMatch.waitForExistence(timeout: 15))

        let settings = app.buttons["settings-button"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        XCTAssertTrue(app.buttons["settings-sync-health-button"].waitForExistence(timeout: 5))
    }

    /// Deterministic replay-controls coverage. Uses AUTOSEED_DETAIL + AUTOSEED_PLAY,
    /// which skip HealthKit entirely (bundled demo workout + route) and open the
    /// detail screen straight into the 3D replay, so the test never depends on
    /// the flaky Health Access permission sheet.
    func testReplayControls() throws {
        let app = XCUIApplication()
        app.launchEnvironment["AUTOSEED_DETAIL"] = "1"
        app.launchEnvironment["AUTOSEED_PLAY"] = "1"
        app.launch()

        // Replay should be active right away.
        let closeButton = app.buttons["replay-close-button"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 15), "Replay screen should start")
        attachScreenshot(named: "04-replay")

        // Timeline scrubber sits at the bottom.
        let timeline = app.sliders["replay-scrub-slider"]
        XCTAssertTrue(timeline.waitForExistence(timeout: 5))
        let summary = app.descendants(matching: .any).matching(identifier: "workout-summary-panel").firstMatch
        XCTAssertFalse(summary.exists, "Replay should keep the map clear of the sliding workout panel")
        XCTAssertFalse(app.buttons["replay-collapse-button"].exists, "Replay should not offer a summary launcher")

        // MapKit supplies the Apple Maps logo and Legal link. The link must
        // stay above the app's bottom sheet/timeline rather than underneath it.
        let legalLink = app.links["Legal"]
        XCTAssertTrue(legalLink.waitForExistence(timeout: 5), "MapKit Legal link should be present")
        XCTAssertLessThan(
            legalLink.frame.maxY,
            timeline.frame.minY,
            "MapKit Legal link must remain above the replay timeline"
        )

        // Reveal the upward fan, then open the speed panel.
        showReplayControls(in: app)
        let speed = app.buttons["replay-speed-button"]
        XCTAssertTrue(speed.exists)
        speed.tap()
        let speedSlider = app.sliders["replay-speed-slider"]
        XCTAssertTrue(speedSlider.waitForExistence(timeout: 5), "Speed slider panel should appear")
        attachScreenshot(named: "04b-speed-panel")
        app.buttons["replay-speed-panel-close"].tap()
        showReplayControls(in: app)

        // Settings button reveals the zoom + 3D sliders.
        let settings = app.buttons["replay-settings-button"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        let zoomSlider = app.sliders["replay-zoom-slider"]
        if !zoomSlider.waitForExistence(timeout: 5) {
            print("=== HIERARCHY AFTER SETTINGS TAP ===\n\(app.debugDescription)")
        }
        XCTAssertTrue(zoomSlider.exists)
        XCTAssertTrue(app.sliders["replay-pitch-slider"].exists)
        attachScreenshot(named: "04c-camera-controls")
        app.buttons["replay-camera-panel-close"].tap()
        showReplayControls(in: app)

        // Pause keeps the replay chrome; resume continues.
        let pause = app.buttons["replay-pause-button"]
        XCTAssertTrue(pause.waitForExistence(timeout: 5))
        pause.tap()
        showReplayControls(in: app)
        XCTAssertTrue(app.buttons["replay-resume-button"].waitForExistence(timeout: 5))
        app.buttons["replay-resume-button"].tap()

        // Back button returns to the detail screen.
        closeButton.tap()
        XCTAssertTrue(app.buttons["replay-play-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "Workout details should return after replay")
        attachScreenshot(named: "05-back-to-detail")
    }

    /// Verifies the app rotates to landscape and stays fully usable on the
    /// detail and replay screens. AUTOSEED_DETAIL skips HealthKit; the app
    /// requests landscape itself (AUTOSEED_LANDSCAPE) because XCUIDevice
    /// rotation is unreliable on this simulator runtime.
    func testLandscapeSupport() throws {
        let app = XCUIApplication()
        app.launchEnvironment["AUTOSEED_DETAIL"] = "1"
        app.launchEnvironment["AUTOSEED_LANDSCAPE"] = "1"
        app.launch()

        // Detail renders in landscape: in landscape the full card is
        // scrollable, so the collapse chevron replaces the drag-down gesture
        // and must be present.
        let playButton = app.buttons["replay-play-button"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 15))
        let collapse = app.buttons["card-collapse-button"]
        XCTAssertTrue(collapse.waitForExistence(timeout: 8), "Collapse chevron should show in landscape")
        XCTAssertTrue(
            app.links["Legal"].waitForExistence(timeout: 5),
            "MapKit Legal link should be visible on the landscape detail map"
        )
        attachScreenshot(named: "06-landscape-detail")

        // Replay works in landscape too.
        playButton.tap()
        XCTAssertTrue(app.buttons["replay-close-button"].waitForExistence(timeout: 10), "Replay should work in landscape")
        XCTAssertTrue(app.sliders["replay-scrub-slider"].waitForExistence(timeout: 5))
        XCTAssertFalse(
            app.descendants(matching: .any).matching(identifier: "workout-summary-panel").firstMatch.exists,
            "The sliding panel should also be absent in landscape replay"
        )
        XCTAssertTrue(
            app.links["Legal"].waitForExistence(timeout: 5),
            "MapKit Legal link should be visible on the landscape replay map"
        )
        showReplayControls(in: app)
        let timeline = app.sliders["replay-scrub-slider"]
        let toggle = app.buttons["replay-controls-toggle"]
        XCTAssertLessThan(toggle.frame.maxY, timeline.frame.minY)
        XCTAssertGreaterThan(toggle.frame.midX, app.frame.midX, "The trigger should sit on the right")
        attachScreenshot(named: "07-landscape-replay")
    }

    /// The deterministic test path uses bundled example workouts and does not
    /// request HealthKit write access or show the Health app permission sheet.
    func testFullWorkoutFlow() throws {
        let app = XCUIApplication()
        app.launchEnvironment["AUTOSEED"] = "1"
        app.launch()

        // Allow the local example data to be installed and rendered.
        sleep(1)

        // Debug capture: what's on screen right now?
        XCTContext.runActivity(named: "Debug UI State") { activity in
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "debug-state"
            attachment.lifetime = .keepAlways
            activity.add(attachment)
        }

        // Workout library (local examples) — wait for at least one workout row.
        // Rows carry the "workout-row" identifier.
        let firstRow = app.buttons.matching(identifier: "workout-row").firstMatch
        guard firstRow.waitForExistence(timeout: 20) else {
            let lines = app.debugDescription.split(separator: "\n").prefix(40).joined(separator: "\n")
            print("=== APP HIERARCHY (first 40 lines) ===\n\(lines)")
            XCTFail("Workout list should load with example data")
            return
        }

        attachScreenshot(named: "02-workout-list")

        // Open the first workout's detail.
        firstRow.tap()
        let playButton = app.buttons["replay-play-button"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 15), "Detail should show play button")
        let detailLegalLink = app.links["Legal"]
        XCTAssertTrue(
            detailLegalLink.waitForExistence(timeout: 5),
            "MapKit Legal link should be visible on the detail map"
        )
        XCTAssertFalse(app.buttons["save-video-button"].exists, "Video export must not be available")
        attachScreenshot(named: "03-detail")

        // Start the 3D satellite replay.
        playButton.tap()
        let closeButton = app.buttons["replay-close-button"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 10), "Replay screen should appear")
        sleep(2)
        attachScreenshot(named: "04-replay")

        // Back button returns to the detail screen.
        closeButton.tap()
        XCTAssertTrue(playButton.waitForExistence(timeout: 10))
    }

    /// The automatic introduction closes once. Manual expansion remains open
    /// until a control is selected or the trigger is tapped again.
    func testReplayMenuIntroduction() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-appAppearance", "dark"]
        app.launchEnvironment["AUTOSEED_DETAIL"] = "1"
        app.launch()
        let play = app.buttons["replay-play-button"]
        XCTAssertTrue(play.waitForExistence(timeout: 15))
        play.tap()

        let toggle = app.buttons["replay-controls-toggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 2))
        XCTAssertEqual(toggle.value as? String, "Expanded")
        attachScreenshot(named: "replay-controls-introduction")

        let collapsed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "Collapsed"), object: toggle
        )
        XCTAssertEqual(XCTWaiter.wait(for: [collapsed], timeout: 6), .completed)
        let hidden = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"), object: app.buttons["replay-pause-button"]
        )
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 3), .completed)
        attachScreenshot(named: "replay-controls-collapsed")

        toggle.tap()
        XCTAssertTrue(app.buttons["replay-pause-button"].waitForExistence(timeout: 2))
        let timeline = app.sliders["replay-scrub-slider"]
        let speed = app.buttons["replay-speed-button"]
        let pause = app.buttons["replay-pause-button"]
        let camera = app.buttons["replay-settings-button"]
        XCTAssertGreaterThan(toggle.frame.midX, app.frame.midX)
        XCTAssertEqual(toggle.frame.maxX, app.frame.maxX - 16, accuracy: 2, "The trigger should align with the right edge of the timeline")
        XCTAssertLessThan(toggle.frame.maxY, timeline.frame.minY)
        XCTAssertLessThan(speed.frame.midY, pause.frame.midY)
        XCTAssertLessThan(camera.frame.maxY, toggle.frame.minY)
        XCTAssertLessThan(pause.frame.maxY, toggle.frame.minY)
        attachScreenshot(named: "replay-controls-manual-fan")
        sleep(4)
        XCTAssertEqual(toggle.value as? String, "Expanded", "Manual expansion should stay open")
        toggle.tap()
        let speedHidden = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"), object: speed
        )
        XCTAssertEqual(XCTWaiter.wait(for: [speedHidden], timeout: 3), .completed)

        app.buttons["replay-close-button"].tap()
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()
        XCTAssertTrue(toggle.waitForExistence(timeout: 2))
        XCTAssertEqual(toggle.value as? String, "Expanded", "Restarting replay should show the introduction again")
        app.buttons["replay-close-button"].tap()
    }

    private func showReplayControls(in app: XCUIApplication) {
        let toggle = app.buttons["replay-controls-toggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        // Dismiss an in-progress introduction before manually reopening it.
        if toggle.value as? String == "Expanded" {
            toggle.tap()
            let closed = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "value == %@", "Collapsed"), object: toggle
            )
            XCTAssertEqual(XCTWaiter.wait(for: [closed], timeout: 3), .completed)
        }
        toggle.tap()
        let opened = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "Expanded"), object: toggle
        )
        XCTAssertEqual(XCTWaiter.wait(for: [opened], timeout: 3), .completed)
        XCTAssertTrue(app.buttons["replay-speed-button"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["replay-speed-button"].isHittable)
    }

    private func attachScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
