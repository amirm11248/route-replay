# Route Replay

Relive every outdoor workout from your Apple Watch — on the map, in 3D.

Import your running, cycling, walking, hiking and other outdoor workouts from Apple Health. Browse them grouped by month, see every stat on a beautiful detail card (distance, pace, heart rate, elevation, weather, steps), then hit play to fly through your route in **3D satellite view**.

## Features

- **HealthKit Sync** — Connects to Apple Health with read-only access and imports only Apple Watch workouts that contain real GPS route data. Route Replay has no app-owned backend; see the [privacy notice](PRIVACY.md) for MapKit details.
- **Workout Library** — Grouped by month with search, summary stats, and activity-type-specific icons.
- **Detail Screen** — Interactive MapKit map with a blue route polyline and visible Apple-provided map attribution. A neutral draggable sheet presents distance, duration, pace, heart rate, elevation and weather; More Detail expands energy, steps and the heart-rate chart. Replay Route stays within easy reach.
- **Appearance** — Platinum light mode and Onyx dark mode, with neutral backgrounds and a restrained cool silver accent in dark mode. Settings offers System, Light and Dark appearance preferences.
- **3D Satellite Flyover** — Press play and the camera follows your route in real-time, rendered with MapKit satellite/flyover imagery and realistic 3D terrain. The workout summary sheet is hidden during replay. A compact matte translucent timeline sits below circular controls that fan upward. The fan appears for three seconds when replay starts, then folds into a button at the right edge above the timeline; tapping it opens the controls again. Controls: pause/resume, speed (0.5×–10×), zoom and 3D depth (1–10). Replays stay in the app; video export is not available.
- **Example Mode** — Tap "Test App with Example Workouts" to open five local sample workouts (two runs, walk, cycle, hike) without HealthKit access. The mode survives relaunches, and Settings always provides a separate Apple Health sync action.

The newest example, **New York Run**, is a 2.54 km counterclockwise lap of the
Stephanie and Fred Shuman Reservoir Running Track in Central Park (16 minutes
of simulated workout time). Its 177 mapped vertices follow the gravel running
track, with replay fixes at most 10 meters apart. It contains no road segments
or street crossings. Distance is calculated from the route; workout metrics
are illustrative. The Berlin run remains available.

New York has Apple Maps Detailed City Experience and Flyover coverage according
to [Apple's feature availability](https://www.apple.com/ios/feature-availability/).
The track and direction are described in the [Conservancy's running guide](https://www.centralparknyc.org/activities/guides/running).
The coordinate data is © OpenStreetMap contributors, under ODbL 1.0; see
[third-party notices](THIRD_PARTY_NOTICES.md). No Apple map imagery is bundled.

## Requirements

- **Xcode 16+** (project built with Xcode 26.6)
- **A physical iPhone or iPad** with HealthKit workout data (the simulator works for demo mode but has no real Health data)
- An **Apple ID** (free) for code signing if running on a real device
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — install with `brew install xcodegen`

## Setup & Build

```bash
# 1. Generate the Xcode project
xcodegen generate

# 2. Open the project
open RouteReplay.xcodeproj

# 3. In Xcode:
#    - Select your team in Signing & Capabilities (free Apple ID works)
#    - Change the bundle ID to something unique (e.g., com.yourname.RouteReplay)
#    - Choose a simulator or your connected iPhone as the run destination
#    - Press Run (⌘R)
```

## Web motion starter

The optional [`web-motion/`](web-motion/README.md) workspace is a React playground for web prototypes. It has GSAP, Lenis and a React Bits component ready to use, with Lenis connected to GSAP ScrollTrigger.

```bash
cd web-motion
npm install
npm run dev
```

## Running Tests

```bash
# Unit tests (route geometry)
xcodebuild test -scheme RouteReplay -destination 'platform=iOS Simulator,name=iPhone 17'

# UI tests (permission screen + local example workflow)
xcodebuild test -scheme RouteReplay -destination 'platform=iOS Simulator,name=iPhone 17' -resultBundlePath /tmp/result.xcresult
```

> **Note on UI tests:** The deterministic example-workout flow does not request
> HealthKit write access, so it does not depend on the Health app permission
> sheet. The Apple Health sync path can still be tested separately on a device
> with Health data.

## Testing on Simulator

1. Launch the app — you'll see the permission screen.
2. Tap **"Test App with Example Workouts"** (DEBUG-only button at the bottom).
3. The five local workouts appear immediately; no HealthKit permission or simulator Health data is required.
4. Use Settings → **Sync with Apple Health** when you want to switch to real data.
5. Tap a workout → detail map + stats → tap play → 3D satellite flyover!

## Architecture

### App Structure

```
.
├── project.yml               # XcodeGen project spec
├── Scripts/
│   └── make_icon.swift       # App icon generator
├── RouteReplay.xcodeproj
├── RouteReplay/
│   ├── App/
│   │   ├── RouteReplayApp.swift    # App entry point
│   │   └── RootView.swift          # Routes permission ↔ library
│   ├── Health/
│   │   ├── HealthKitManager.swift  # Source switching, queries, caching
│   ├── Models/
│   │   ├── WorkoutEntry.swift      # Data model + activity-type styling
│   │   ├── ExampleWorkoutData.swift # Local test workouts and routes
│   ├── Views/
│   │   ├── PermissionView.swift    # Onboarding / Health connect
│   │   ├── WorkoutListView.swift   # Month-grouped library + source settings
│   │   ├── AppSettingsView.swift   # Example mode + Apple Health sync
│   │   ├── WorkoutDetailView.swift # Map + route polyline + play
│   │   ├── WorkoutStatsCard.swift  # Integrated summary + HR chart
│   │   ├── AppTheme.swift          # Platinum / Onyx semantic colors
│   │   ├── GooeyAddMenu.swift       # Upward fan + matte replay material
│   │   ├── ReplayMapView.swift     # MapKit route map + camera coordinator
│   │   └── WorkoutDetailView+Previews.swift  # Mock data for Xcode Previews
│   └── Assets.xcassets/           # App icon + accent color
├── RouteReplayTests/
│   └── RouteGeometryTests.swift    # Math tests (bearing, interpolation)
└── RouteReplayUITests/
    └── WorkoutFlowUITests.swift    # Deterministic demo-flow UI tests
```

### Key Design Decisions

| Concern | Approach |
|---|---|
| **HealthKit API** | Read-only `HKSampleQuery` + `HKWorkoutRouteQuery` for real workouts and metrics (iOS 16+). Example mode stays entirely in-app. |
| **Map framework** | MapKit through `MKMapView`/`MKMapCamera`; map tiles and imagery are provided at runtime by Apple. |
| **3D Satellite** | `MKMapView.mapType = .satelliteFlyover`; maps are rendered live in the app. |
| **Replay engine** | Distance-based interpolation on a resampled polyline with anticipatory heading and frame-paced MapKit camera updates. |
| **Heart rate chart** | Swift Charts (`Chart { LineMark + AreaMark }`) with a subtle theme-colored fill. |
| **Stats card** | Opaque neutral surface, adaptive metric layout and SF Symbols. |
| **Appearance** | Semantic dynamic colors and a persisted System / Light / Dark preference. |
| **Weather data** | Read from `HKWorkout.metadata` keys (`HKMetadataKeyWeatherTemperature`, `HKMetadataKeyWeatherHumidity`). |

### Platform Target

- **iOS 17.0+** — MapKit, Swift Charts, and the camera APIs used by this project are available from iOS 17.
- **Not macOS / iPad-only / visionOS** — HealthKit GPS routes require iOS.

## Screenshots and demo media

The repository intentionally contains no screenshots, video files, map tiles, or real workout files. Run the UI tests with `-resultBundlePath` to generate local screenshot attachments for review. The app does not export or save replay videos.

## Privacy

HealthKit data is processed on-device and Route Replay has no app-owned server, analytics, or advertising SDK. The normal sync path requests read permission only; example mode does not use HealthKit at all. MapKit may load map content from Apple when maps are displayed. See [PRIVACY.md](PRIVACY.md).

## License

This project is intended to be released under the [MIT License](https://opensource.org/license/mit/).
The repository is not licensed under MIT until a top-level `LICENSE` file is
added with the correct copyright holder and the owner has confirmed the rights
to all original source code and assets.

The MIT License applies only to original Route Replay work that the copyright
holder is entitled to license. It does not grant rights to Apple's SDKs,
Apple Maps content, HealthKit data, or other third-party materials, which
remain subject to their own terms.

MIT is a permissive license and does not impose a noncommercial-only
restriction. That is compatible with this project being free and noncommercial
today, but it means other people may commercially use and redistribute their
own copies under the license terms.

## Acknowledgements

Route Replay uses Apple’s SwiftUI, HealthKit, MapKit, Core Location, UIKit, Swift Charts, and SF Symbols APIs. Apple’s SDKs and map services are used through the platform and are not redistributed in this repository. Apple does not sponsor or endorse Route Replay.

Apple, Apple Watch, HealthKit, SF Symbols, and SwiftUI are trademarks of Apple
Inc., registered in the U.S. and other countries and regions. Route Replay is
not affiliated with, sponsored by, or endorsed by Apple Inc.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the dependency audit and [SECURITY.md](SECURITY.md) for reporting guidance.
