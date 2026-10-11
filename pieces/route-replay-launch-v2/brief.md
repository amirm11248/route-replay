# Route Replay — revision 2

Status: the user approved the revised board and requested rendering. The 30-second animation and measured review are complete, with the three requested portrait recording placeholders.

## Requested correction

The user found the first trailer's scenes too similar and clarified that all screen recordings will be vertical. Rework the composition, scale, lighting and subject treatment of the entire board. Preserve the approved 30-second duration, widescreen output, music-only format, story sequence, pure white / navy / cool slate palette, and three short recording windows. Real footage is still deferred.

Use the existing Clean Sketch drawing kit with clean sans type. Study the parent style and original launch reference contact sheet, rather than repeating the first draft's left-headline/right-small-diagram formula. In this revision vary the stage as well as the object: panoramic sketch, dark type-and-play graphic, three portrait arrangements, an open metric triptych, extreme close-up, large dimensional terrain, and a genuine app-brand close.

## Static board and intended bridges

| Panel | Time | Revised framing | Transition intention |
|---|---|---|---|
| 1 | 0–3 | Single centered headline above a panoramic route landscape. | The route endpoint grows into the next play mark. |
| 2 | 3–6 | Deep navy field; oversized play ring; large white Replayed. line. | The ring opens into a portrait recording frame. |
| 3 | 6–8 | Right portrait recording; left stacked copy and small route detail. | Continue into the illustrated metrics. |
| 4 | 8–11 | Three open metric illustrations: distance, heart rate, elevation. | Match the pulse shape to the detail clip. |
| 5 | 11–13 | Left portrait recording; a deep navy right panel with white type. | Push into the play action. |
| 6 | 13–17 | Extreme close-up of a navy disc cropped by the frame; restrained copy opposite it. | One second of silence, then the replay reveal. |
| 7 | 17–20 | Centered portrait recording against dark terrain contours; large 3D copy beside it. | Pull out into the physical terrain sketch. |
| 8 | 20–23 | Large isometric landform across the frame; low headline and small upper cue. | Return to the carried route in a new framing. |
| 9 | 23–26 | Close panoramic route in cool blue on navy; centered white copy above. | Resolve into the actual app's identity. |
| 10 | 26–30 | The user's real app icon and bold wordmark on white, with the GitHub CTA. | Quiet final brand hold. |

The three clips occupy native portrait-shaped inserts at right, left and center. Their timing stays 6–8s, 11–13s and 17–20s. Use `fit: contain` and preserve the real source ratio; do not crop away status, controls or attribution. Reserve a 432 × 936 phone-shaped envelope per insert. The exact positions are in `recording-slots.json`.

The only bitmap included in this board is the user's own `RouteReplay/Assets.xcassets/AppIcon.appiconset/AppIcon.png`, copied into `assets/app-icon.png`. Its original navy/orange appearance is retained only in the genuine brand close. No screen recordings, product screens, map imagery or reference-film pixels are included.

## Facts and sources

The app flow, replay and controls were checked in revision 1 against the project's SwiftUI source and existing UI tests. This visual revision introduces three metric labels, all present in `WorkoutStatsCard.swift`: Distance, Heart Rate and Elevation. No invented numeric workout data appears.

Web checks on 2026-10-10: [Apple's distanceWalkingRunning documentation](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/distancewalkingrunning), [quantity-type identifiers including heartRate](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier), and [HKMetadataKeyElevationAscended](https://developer.apple.com/documentation/healthkit/hkmetadatakeyelevationascended). These establish the platform data types; the local source establishes what this app actually displays. The revision-1 [MapKit source](https://developer.apple.com/documentation/mapkit/mkmaptype) still grounds the replay label. 3D coverage varies by available map data.

## Review process

This revision changes every composition, so all ten static panels were shown for the animate skill's storyboard check. The user explicitly approved and requested rendering. The existing story and sound arc were retained. Revision 1 remains in its original piece; the static `storyboard.png` records the approved revised compositions.

## Delivery and validation

`renders/final.mp4` is the 30.000s, 1920 × 1080, 30 fps master with 900 frames. `renders/share.mp4` is the smaller sharing encode at the same resolution. `index.html` is a self-contained seekable preview with procedural music and the user's app icon embedded.

All 8 hard cuts and the iris bridge are on the 120 BPM grid. All 5 story-arc rules pass. Text placement passes on 160 sampled frames with zero clipping, overlap or unsafe strings. No flat/blank frames or still stretches over 3s remain. A 35-frame whole-piece deterministic seek check passed; the 5 corrected iris samples also passed. The unchanged score measures −14.6 LUFS integrated, −1.1 dBFS true peak, with its largest 100ms window at 17.0s after 1.4s at or below −40 dBFS.

Visual review covered all ten per-shot sheets, the phone overview and the actual-frame cut/iris sheets. The review caught a dark gap during the expanding-circle transition; keeping the white play mark visible corrected it. Human listening remains unverified. The central replay placeholder is the weakest visual proof until the user supplies the real clip. No real screen recordings have been added.
