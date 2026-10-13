<p align="center">
  <a href="https://github.com/amirm11248/route-replay/blob/main/pieces/route-replay-launch-v6/renders/final.mp4">
    <img src="docs/assets/trailer-cover.svg" width="100%" alt="Route Replay launch film artwork — follow a glowing route over a stylized map. Click to watch the MP4 trailer." />
  </a>
</p>

<h1 align="center">Route Replay</h1>
<p align="center"><strong>Your workout was the journey. This is the replay.</strong></p>
<p align="center">
  An open-source iPhone app that turns GPS workouts from Apple Health into interactive 3D route replays.
</p>
<p align="center">
  <a href="https://github.com/amirm11248/route-replay/blob/main/pieces/route-replay-launch-v6/renders/final.mp4"><strong>▶ Watch the trailer</strong></a>
  &nbsp;·&nbsp;
  <a href="https://route-replay.roger72141.chatgpt.site">Project website</a>
  &nbsp;·&nbsp;
  <a href="#run-it-yourself">Build the app</a>
  &nbsp;·&nbsp;
  <a href="PRIVACY.md">Privacy</a>
</p>

---

### From activity data to a new point of view

Route Replay reads supported outdoor workouts and their GPS routes from Apple Health, puts the route back on a map, and moves a 3D camera along the path. Instead of another static workout summary, you can revisit the route you actually took.

**Made for runners, cyclists, hikers, and anyone who records outdoor workouts with an Apple Watch.**

| Explore | Replay | Understand |
| :--- | :--- | :--- |
| Browse workouts by month, activity and search. | Follow your route through Apple Maps satellite/3D imagery. | See distance, duration, pace, heart rate, elevation, energy and available weather data. |
| Read-only Apple Health integration. | Pause, resume, change speed (0.5×–10×), zoom and 3D depth. | Route, workout stats and heart-rate chart in one place. |

### Watch the launch film

**[Play the Route Replay trailer ↗](https://github.com/amirm11248/route-replay/blob/main/pieces/route-replay-launch-v6/renders/final.mp4)** — MP4, approximately 8.8 MB.

The film is a project showcase; it is not an in-app export. Route Replay **does not currently support exporting replay videos**. Live satellite imagery and 3D detail depend on Apple Maps coverage and the device/network environment.

### Run it yourself

This is a source-code project, **not an App Store download**. You'll need a Mac with Xcode, and an iPhone for real HealthKit data. An iOS Simulator can run the included example-workout flow.

**Requirements:** iOS 17+, Xcode 16+ (currently maintained with Xcode 26.6), [XcodeGen](https://github.com/yonaskolb/XcodeGen), and an Apple ID for on-device signing. The app target is **iPhone**, not iPad.

~~~bash
git clone https://github.com/amirm11248/route-replay.git
cd route-replay
brew install xcodegen   # if not already installed
xcodegen generate
open RouteReplay.xcodeproj
~~~

In Xcode:

1. Select the **RouteReplay** scheme.
2. For a physical iPhone, choose your signing team and set a unique bundle identifier in **Signing & Capabilities**.
3. Select an iPhone simulator or your connected iPhone, then press **Run** (⌘R).
4. For a simulator demo, use **Test App with Example Workouts** on the first screen. That onboarding shortcut is available in **DEBUG builds only**.
5. Open a workout, inspect the route and stats, then start a 3D replay. To use real workouts, grant **read-only** Apple Health access on a supported device.

The examples include a New York Central Park Reservoir route and a Berlin run. Example metrics are illustrative, not exports of anyone's Health data.

### How it works

~~~text
Apple Health / bundled examples
             ↓
     Workout + GPS route
             ↓
      Route resampling
             ↓
 Camera heading + interpolation
             ↓
     MapKit 3D flyover
~~~

- **UI:** SwiftUI, UIKit, Swift Charts
- **Workout import:** HealthKit workout and route queries; example data stays local
- **Map and camera:** MapKit with distance-based interpolation, route resampling, and adjustable camera playback
- **Persistence:** UserDefaults for selected source/appearance preferences; no app-owned account system, analytics SDK, or backend
- **Map content:** loaded by Apple's MapKit services; Apple Maps availability and terms apply

The native application is in [RouteReplay/](RouteReplay/), the XcodeGen project spec is [project.yml](project.yml), and tests live in [RouteReplayTests/](RouteReplayTests/) and [RouteReplayUITests/](RouteReplayUITests/). The separate [web-motion/](web-motion/) workspace contains an optional React/Vite project website.

### Tests

Use an installed iPhone simulator destination; substitute the name to match your Xcode installation.

~~~bash
xcodebuild test \
  -project RouteReplay.xcodeproj \
  -scheme RouteReplay \
  -destination 'platform=iOS Simulator,name=iPhone 17'
~~~

The Swift test target exercises route geometry. UI tests cover the onboarding and example-workout flow without writing to HealthKit. Tests have **not been certified as passing on every Xcode/device combination**.

### Privacy by design

- Requests **read access only** to relevant workouts, GPS routes, heart rate and related workout data.
- Processes imported Health data on-device; no Route Replay server or account.
- Example mode does not request HealthKit access.
- MapKit may contact Apple's services to display maps and satellite imagery.
- No built-in replay-video export or Photos access.

Read the [technical privacy notice](PRIVACY.md) before distribution. It is explicitly a **repository draft**, not a finalized App Store privacy policy. Never post personal GPS routes or HealthKit records in issues.

### Project status & contributing

Route Replay is a **personal open-source hobby project**, currently developed without monetization. Issues and focused pull requests are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), and [PROJECT_STATUS.md](PROJECT_STATUS.md). GitHub hosts source code, not a ready-to-install binary.

**License:** Original code, documentation and original assets are [MIT licensed](LICENSE). Third-party material has separate terms; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Apple Maps content and Apple trademarks are not relicensed. Route Replay is not affiliated with or endorsed by Apple.
