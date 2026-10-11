# Route Replay launch trailer

Status: complete with the three requested recording placeholders. The user approved the full storyboard and corrected white/navy/slate palette on 2026-10-10. Export and measured review passed; real recordings are intentionally deferred.

## Intent and agreed specification

Make a GitHub launch trailer for the user's iOS app. The central idea is: your workout becomes a route you can relive. A navy route line carries the eye from the opening sketch, through three brief product demonstrations, and back to the opening path, now replayed.

The user chose 30 seconds, widescreen, music only. Delivery target: 1920 × 1080, 16:9, 30 fps, 900 frames, a procedural score at 120 BPM. The user explicitly requested placeholders for screen recordings now and will supply recordings later. No recordings or product screenshots are embedded in this stage.

Use the existing `styles/clean-sketch` hybrid: Clean Launch composition, sentence-case type, springs and navy/slate depth; Sketchbook paper, graphite construction, restrained handwritten emphasis and pencil hatching. Inspect the parent's samples and demos before drawing. The app's runtime accent is blue; the trailer preserves the user's darker launch palette rather than recoloring real footage.

Look revision: the user selected "Make it cleaner and more minimal" after the first three frames. Revised to predominantly clean sans typography, pearl `#f9f9f7`, almost imperceptible paper tooth, precise panel edges and no notebook binding. The route's graphite construction and the dimensional landform carry the sketchbook influence. Keep navy/slate depth for the payoff. The parent reusable style is unchanged.

Final palette direction from the user: "dont use light yellow kind of colour use white and premium colours". Use pure `#ffffff` for the stage and surfaces, `#243e58` navy for the route, cool slate `#687b8e` for secondary type, and cool `#f3f6fa` / `#f8fafc` for placeholder and landform surfaces. Remove every cream/yellow-tinted fill in this piece. Apply this correction to all ten static panels for the combined look/storyboard check.

## Format and story

F8 (claims → proof trailer) best matches a launch trailer with short product recordings. The animate format card marks F8 provisional; it has not been proven by a full piece in this kit. This piece is a new application of the existing eight-second Clean Sketch study.

| Panel | Time | Picture / copy | Bridge | Sound |
|---|---|---|---|---|
| 1 | 0–3 | Your workout. A navy route begins on pearl paper. | Carry its endpoint into the title. | Quiet motif and pencil texture. |
| 2 | 3–6 | Replayed. Introduce Route Replay. | Endpoint becomes a play mark. | Rising restrained notes. |
| 3 | 6–8 | Recording placeholder 01: choose a workout. | A clean recording frame opens from the sketch. | Tactile click; flat bed. |
| 4 | 8–11 | See the effort. Route becomes an abstract heart-rate sketch. | Match its curve to the detail-screen recording. | Small dry rhythmic clicks. |
| 5 | 11–13 | Recording placeholder 02: workout details. | Pull into the play action. | Quiet continuation. |
| 6 | 13–17 | Then press play. Extreme close-up of a drawn play mark. | Hold before the 3D replay. | All score events finish before 16s; silence 16–17s. |
| 7 | 17–20 | Recording placeholder 03: 3D satellite replay. | Pull out to the illustrated route gaining depth. | Loudest hit at 17s, then a flat warm chord. |
| 8 | 20–23 | Same route. New perspective. The illustrated route gains depth. | Return to the opening route silhouette. | Warm held harmony; soften. |
| 9 | 23–26 | Relive your route. Opening path returns, changed. | Collapse the replay motif into the closing composition. | Resolving motif. |
| 10 | 26–30 | Route Replay. Explore on GitHub. | Final title with the completed route; subtle life during hold. | Gentle decay, no large final hit. |

The user approved this beat sequence, reviewed three look frames, asked for less sketchbook decoration, then specified pure white and premium colors. The final "Approve storyboard" choice approved all ten panels and the corrected palette. The static `storyboard.png` remains the approval record. The browser contains a seekable animated preview with procedural music, built from the same scene functions.

## Product evidence and claim checks

Product behavior was checked against the actual project, rather than inferred from the older README. `WorkoutListView.swift` implements the month-grouped searchable library. `WorkoutStatsCard.swift` implements the workout's statistics and heart-rate graph. `WorkoutDetailView.swift` implements play, pause/resume, a scrubber, speed 0.5×–10×, zoom and camera depth. `ReplayMapView.swift` switches from a standard map to `satelliteFlyover` and applies route-following camera commands. `WorkoutFlowUITests.swift` documents and exercises the example-data library → detail → replay flow.

Web searches on 2026-10-10 checked MapKit flyover and the app's public discoverability. Apple's primary documentation describes satellite flyover data as available where provided: [MKMapType](https://developer.apple.com/documentation/mapkit/mkmaptype), [mapType](https://developer.apple.com/documentation/mapkit/mkmapview/maptype). A search for `site:github.com "RouteReplay" "workouts"` did not establish a public repository; the closing GitHub text is the user's intended destination, and no repository URL is invented.

| Screen wording | Nature / supporting evidence |
|---|---|
| Your workout. / Replayed. / Relive your route. | Creative wording grounded in the route replay implementation; no numerical, superlative or universal claim. |
| Pick a workout. | Instruction supported by `WorkoutListView` and the existing end-to-end UI test. |
| See the effort. / Workout details | Creative wording and a feature label supported by `WorkoutStatsCard`. No invented health data appears. |
| Then press play. / 3D satellite replay | Action and feature label supported by `WorkoutDetailView`, `ReplayMapView` and the Apple sources above. Do not imply 3D imagery is available everywhere. |
| Same route. New perspective. | Creative wording for the actual change to a pitched route-following map camera. The storyboard illustration is explicitly a sketch, not simulated app UI. |
| Route Replay | Product name verified in `Info.plist` and `project.yml`. |
| Explore on GitHub. | Intended launch CTA requested by the user; actual URL remains pending. |

Do not add App Store availability, video export, a license label, performance numbers, universal flyover coverage, or claims of being first. The app source does not implement replay video export. The repository's README says its intended MIT license has not yet been completed.

## Recording slots

Three fixed windows totaling seven seconds are declared in `recording-slots.json`: library 6–8s; details 11–13s; replay 17–20s. Reserve a 16:9 insert at x=288, y=240, width=1344, height=756. Hold the insert geometry still while each recording is visible, so supplied footage can be composited without changing timing or the surrounding artwork. Draw explicit placeholder text only within the replaceable rectangle. Keep labels that belong in the final trailer above that rectangle.

The later footage-compositing step is separate from the current procedural canvas build. Confirm supplied clips' dimensions and show their original UI without inventing, stretching, or hiding essential map content. The capture guide records the exact actions and durations. Real footage is absent at the user's request.

## Inspection limits

The app compiled into `/tmp/route-replay-launch-explore/Build/Products/Debug-iphonesimulator/RouteReplay.app`. The XcodeBuildMCP build-and-run tool timed out after 300 seconds; Simulator automation then timed out creating its remote session, and the native computer-use pipe could not start. Thus a live visual review could not be completed in this session. Source and existing UI-test coverage establish the proposed actions, but no claim of a successful runtime walkthrough is made.

## Final delivery and review

`renders/final.mp4` is the 1920 × 1080, 30 fps master, with 900 video frames and a 30-second timeline. `renders/share.mp4` is the smaller H.264/AAC sharing encode at the same resolution. The self-contained animated preview is `index.html`. All footage slots remain placeholders.

Final review: all eight cuts and the intro morph are on the 120 BPM grid; no flat/blank frames; no still stretches over three seconds; zero text issues across 160 sampled frames; all five story-arc rules pass; 29 deterministic seek samples pass. The procedural score measures −14.6 LUFS integrated with −1.1 dBFS true peak. Its loudest 100ms window begins at 17.0s and is preceded by 1.4s at or below −40 dBFS. The review caught and corrected a 3.1s closing hold. Inspected every shot's contact sheet, the cut/morph sheets and the phone overview.

The weakest scene is the 3D replay placeholder: the real app's visual proof arrives when the user supplies their clip. A human listening review has not been performed; the sound checks are numeric.
