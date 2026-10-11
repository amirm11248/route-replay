import SwiftUI
import UIKit

/// Top-level switch: shows onboarding until either Apple Health is connected
/// or local example mode is selected. Example mode is persisted by the
/// manager, so closing and reopening the app returns to the same test screen.
struct RootView: View {
    @EnvironmentObject private var health: HealthKitManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if health.isReady {
                WorkoutListView()
            } else {
                PermissionView()
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: health.isAuthorized)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: health.isUsingExampleWorkouts)
        .task {
            await health.restoreSession()
            #if DEBUG
            let env = ProcessInfo.processInfo.environment
            if env["AUTOSEED_LANDSCAPE"] == "1" {
                // UI verification: rotate the app to landscape. XCUIDevice
                // rotation is unreliable on some simulator runtimes, so the
                // app requests the geometry change itself.
                Self.requestLandscape(attempt: 1)
                try? await Task.sleep(for: .milliseconds(700))
                Self.requestLandscape(attempt: 2)
                try? await Task.sleep(for: .milliseconds(1200))
                Self.requestLandscape(attempt: 3)
            }
            if env["AUTOSEED"] == "1", !health.isReady {
                // UI tests: load local sample workouts without HealthKit.
                await health.loadSampleData()
            } else if env["AUTOSEED_DETAIL"] == "1", !health.isReady {
                // Pure-UI verification mode: skip HealthKit entirely and open
                // the detail screen with a bundled demo workout.
                health.isAuthorized = true
            }
            #endif
        }
    }

    #if DEBUG
    private static func requestLandscape(attempt: Int) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            Self.logRotate("attempt \(attempt): no UIWindowScene")
            return
        }
        let before = scene.interfaceOrientation.rawValue
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight)) { error in
            Self.logRotate("attempt \(attempt): before=\(before) ERROR \(error.localizedDescription)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Self.logRotate("attempt \(attempt): before=\(before) after=\(scene.interfaceOrientation.rawValue)")
        }
    }

    private static func logRotate(_ message: String) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent("rotate_log.txt")
        let line = "\(Date()) \(message)\n"
        if let data = line.data(using: .utf8), FileManager.default.fileExists(atPath: url.path) {
            if let fh = try? FileHandle(forWritingTo: url) {
                fh.seekToEndOfFile()
                fh.write(data)
                try? fh.close()
            }
        } else {
            try? line.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    #endif
}
