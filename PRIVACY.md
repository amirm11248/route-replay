# Route Replay privacy notice

**Status:** repository draft  
**Last reviewed:** 2026-08-17

**Maintainer:** [Malik Abdullah Amir](https://github.com/amirm11248). The
repository's current personal hobby purpose is described in
[PROJECT_STATUS.md](PROJECT_STATUS.md). This purpose does not replace the
disclosures needed for a distributed app.

This notice describes the behavior of the source in this repository. If Route
Replay is distributed through the App Store, publish the final notice at a
stable public URL and review it against the actual release build and the
operator's legal details.

Apple's HealthKit guidance requires a privacy policy for apps that use
HealthKit, including a clear explanation of how the health data is used. A
free or noncommercial release is not a substitute for that disclosure. Before
any App Store submission, replace this repository draft with a stable public
privacy-policy URL and add the operator's real contact details.

See Apple's [guidance on protecting HealthKit
privacy](https://developer.apple.com/documentation/healthkit/protecting-user-privacy).

## What Route Replay can access

When a person chooses to connect Apple Health, Route Replay requests read-only
access to the HealthKit data needed to display outdoor workout replays:

- workouts and workout activity types;
- workout GPS routes;
- heart rate samples;
- step count, energy, distance, and flights-climbed quantities; and
- weather metadata attached to a workout, when present.

Route Replay does not request HealthKit write access and does not write samples
back to HealthKit. Example mode uses bundled demo data and does not access
HealthKit.

## How data is used

HealthKit data is processed on the device to build the workout list, detail
screen, and route replay. This project contains no app-owned server, account
system, analytics SDK, advertising SDK, or database backend. The app does not
upload HealthKit records to a Route Replay service.

Map views use Apple's MapKit services. MapKit may load map content from Apple
using the map region needed to display the route. Apple's terms and privacy
practices apply to that service; the repository does not include downloaded map
tiles or a copy of Apple's map database. Route Replay does not export or save
replay videos and does not request Photos access.

## Local storage and retention

The normal release path keeps imported workout data in memory for the current
session. UserDefaults stores only the selected source state (example mode or
Apple Health connected); it is not used as a HealthKit export.

There are no release features that write workout data or rendered media to the
app's Documents directory. Revoking HealthKit access through Apple's system
settings prevents future reads.

## Demo data

Example workouts are hard-coded local fixtures with fabricated workout metrics.
The Berlin route uses public landmarks. The New York example follows a public
running track using OpenStreetMap coordinates under the licenses in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Neither is imported from a
user's workout history. No real workout export, HealthKit dump, or GPX/FIT/TCX file is
included here. The separate launch-film MP4 is promotional project media; its
presence does not mean that the app records or exports replay videos.

## Contact and scope

For a repository issue, use the private reporting guidance in
[`SECURITY.md`](SECURITY.md) rather than posting health data or credentials in
public. This document is a technical repository notice, not legal advice or a
substitute for the final privacy disclosures required for a particular
distribution channel or jurisdiction.
