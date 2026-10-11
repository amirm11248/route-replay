# GitHub legal & safety pre-publication checklist

**Project:** Route Replay  
**Audit date:** 2026-08-17  
**Scope:** current working tree only; this folder was not a Git repository when
the audit started, so there is no local commit history to inspect.

## Status legend

- `[x]` verified from the current working tree or automated check
- `[~]` partly verified; owner or release-time action remains
- `[ ]` unresolved or must be done after the GitHub repository exists
- `N/A` not applicable to the current project

## Release gate

**Not fully green yet.** The source tree is clean enough for a reviewed first
commit, but publication still depends on ownership/copyright confirmation, the
copyright-holder line in the intended MIT license, a final MapKit attribution
check, and GitHub security settings after the repository is created.

## 1. Ownership of the code

- `[~]` Authorship and permissions cannot be proven from files alone.
- `[x]` No copied project, vendor source, tutorial attribution, or external
  source notice was found in the current tree.
- `[ ]` The owner must confirm that no code came from an employer, school,
  client, paid template, private repository, tutorial, or answer whose terms
  prohibit redistribution.

## 2. Third-party Swift packages and libraries

- `[x]` No `Package.swift`, `Package.resolved`, Podfile, Cartfile, framework, or
  XCFramework was found.
- `[x]` `THIRD_PARTY_NOTICES.md` records the audit and the Apple platform APIs.
- `[~]` Recheck any dependency or manually copied file added later.

## 3. Repository license

- `[x]` The owner chose the MIT License for the original Route Replay work.
- `[x]` The README explains that MIT does not restrict downstream commercial
  use; the owner's current decision not to earn money does not change that.
- `[ ]` Add the standard top-level `LICENSE` file with the actual copyright
  holder's name before the first public commit.
- `[~]` Confirm that every source file and original asset being licensed is
  owned by, or legally licensable by, that copyright holder.

## 4. Apple SDK/code

- `[x]` Apple frameworks are referenced through imports only.
- `[x]` No Apple SDK files, Xcode application, certificates, or framework copies
  were found.
- `[~]` Recheck any future binary or generated archive before committing it.

## 5. Apple Maps display

- `[x]` The app requests map content through MapKit at runtime; no tile cache,
  extracted terrain/building data, scraper, or map database is present.
- `[x]` The map keeps MapKit's system-provided Apple Maps logo and Legal link;
  the app does not recreate, hide, alter, or obscure those notices. Public
  layout margins reserve space above the draggable card and replay timeline;
  landscape uses a compact scrollable card so MapKit still has room to render
  its attribution controls.
- `[~]` Verify the attribution placement on a physical device after any future
  map or bottom-sheet layout changes; MapKit controls are supplied by Apple at
  runtime and can vary by OS version.
- `[x]` Video export has been removed from the app, including the Photos
  permission, renderer, UI, debug hook, and test path. No rendered map media is
  included.

## 6. Real workout data

- `[x]` No GPX, FIT, TCX, JSON/CSV export, HealthKit dump, coordinate log, or
  rendered workout media was found.
- `[x]` Bundled fixtures use fabricated metrics; the Berlin route is a public
  landmark demo path, not a user's workout history.
- `[~]` Owner must confirm no private source data was copied before this audit.

## 7. HealthKit

- `[x]` The app requests read-only access (`toShare: []`) and includes the
  HealthKit capability and read purpose string.
- `[x]` Permission denial is handled and the debug example path does not write
  synthetic samples to HealthKit.
- `[x]` `PRIVACY.md` documents the HealthKit data categories and on-device use.
- `[~]` Test the real HealthKit path on a physical device and publish the final
  privacy notice at a stable URL before App Store distribution.

## 8. API keys and secrets

- `[x]` Repository-wide text scan found no API keys, tokens, passwords, bearer
  headers, private keys, cloud credentials, or `.env` files.
- `[x]` `.gitignore` now excludes common secret/configuration formats.
- `[~]` Repeat the scan against the staged first commit before the first push.

## 9. Apple signing material

- `[x]` No `.p12`, `.p8`, certificate, provisioning profile, private key, or
  signing credential was found.
- `[x]` `DEVELOPMENT_TEAM` is empty; signing is not tied to the owner's account.
- `[~]` Select the owner's team locally in Xcode and do not commit signing files.

## 10. Git history

- `[~]` An empty Git repository now exists, but it has no commits or history,
  so historical-secret scanning is not applicable yet.
- `[ ]` If this project has ever existed in another repository or folder, search
  that history before publishing; revoke/rotate any credential ever exposed.

## 11. Personal information

- `[x]` Text scan found no private email, phone number, address, Apple ID,
  device UDID, IP address, or personal filesystem path in source/docs.
- `[x]` Xcode user state and desktop metadata are now ignored.
- `[~]` Do not upload the existing local `.DS_Store`, `.freebuff/`, or
  `xcuserdata` files through a zip/manual file picker.

## 12. `.gitignore`

- `[x]` Added rules for macOS/Xcode state, build output, secrets, workout files,
  rendered media, logs, and test results.
- `[~]` Verify the staged file list with `git status --short` before pushing.

## 13. Images and graphics

- `[x]` No README screenshots, docs images, map screenshots, GIFs, or videos are
  present.
- `[x]` The custom app icon is generated by the repository's own
  `Scripts/make_icon.swift` source rather than copied from an external image.
- `[~]` The owner must still confirm the icon's authorship and permission to
  license it with the project.

## 14. Fonts

- `N/A` No bundled font files were found; the app uses system fonts.

## 15. Icons

- `[x]` UI icons are referenced as system SF Symbols rather than a bundled icon
  pack.
- `[x]` No SF Symbols artwork is copied into the repository; the app references
  Apple's system API.
- `[~]` Confirm the custom app icon's provenance and permission.

## 16. Music/audio in demo videos

- `N/A` No audio, music, promotional video, or GIF is included.

## 17. App name

- `[~]` A web search found multiple products using “route replay” as a generic
  feature phrase. This is not trademark clearance; check the intended markets
  if the name will be commercial or published in the App Store.

## 18. Apple branding

- `[x]` The project does not call itself an official Apple product and the icon
  is not an Apple logo.
- `[x]` README and third-party notices include an Apple trademark and
  non-affiliation acknowledgment.
- `[~]` Keep Apple product names descriptive and review any future marketing
  copy for implied sponsorship or endorsement.

## 19. Apple Maps screenshots in README

- `[x]` No map screenshots are currently included.
- `[~]` If screenshots are added, retain MapKit attribution and identify them as
  app output rather than owned map imagery.

## 20. Demo workout routes

- `[x]` Demo workouts are local fixtures and no real user's route is included.
- `[~]` Replace the public-landmark path with an abstract route if a strictly
  synthetic fixture is required; never add a personal route for screenshots.

## 21. Backend/server configuration

- `N/A` No backend, production URL, admin endpoint, database, or server key is
  present.

## 22. Firebase/cloud files

- `N/A` No Firebase, Supabase, AWS, CloudKit, or service-account configuration
  is present.

## 23. Test accounts

- `N/A` No accounts, usernames, passwords, OAuth tokens, or session cookies are
  used by the project.

## 24. Debug logs

- `[x]` No debug export log, verification movie, or export hook remains.
- `[~]` Do not share future debug files generated from real HealthKit data.

## 25. Crash reports

- `N/A` No crash reports or diagnostic dumps are included.

## 26. README claims

- `[x]` README claims now distinguish on-device HealthKit processing from
  MapKit's Apple service and avoid “never sends data anywhere” language.
- `[x]` README no longer claims MIT without a license file or copyright decision.

## 27. README acknowledgements

- `[x]` Added an Acknowledgements section and linked the dependency audit.
- `[x]` README states that Apple does not sponsor or endorse the project.
- `[x]` README and `THIRD_PARTY_NOTICES.md` identify the relevant Apple marks
  descriptively and state that the project is not affiliated with Apple.

## 28. Repository files

- `[x]` README, `.gitignore`, privacy notice, third-party audit, security policy,
  Xcode project/spec, source, unit tests, and UI tests are present.
- `[ ]` Add `LICENSE` with the standard MIT text and the correct copyright
  holder before publication.

## 29. Copyright notice

- `[ ]` Add the copyright-holder name to `LICENSE` only after the owner confirms
  the exact person or organization that owns the original work.
- `[x]` Do not claim ownership over Apple SDKs, Apple Maps content, HealthKit
  records, or third-party assets.

## 30. Germany / business side

- `[~]` The repository can be treated as a personal noncommercial project only
  if that matches the owner's facts: no paid download, subscription, ads,
  sponsorship, paid API, or commercial customer contract. Reassess before
  monetization and obtain appropriate German legal/tax advice.

## 31. Accidental Apple/proprietary files

- `[x]` File-size/type review found only normal source, project files, and the
  1024×1024 app icon; no Apple software, map tiles, certificates, or binaries.
- `[x]` Local desktop/workspace state is excluded by `.gitignore`.

## 32. GitHub security settings

- `[ ]` After creating the repository, enable/review secret scanning, push
  protection, Dependabot alerts, and code scanning where available.
- `[ ]` Review the Security page and investigate every alert; do not bypass a
  warning without understanding it.

## 33. Final manual repository review

- `[~]` Source, plist, entitlements, tests, fixtures, assets, and docs were
  reviewed in the current working tree.
- `[ ]` Repeat the review against the actual staged commit and public GitHub
  view, including its complete history and generated file list.

## 34. Final legal gate for this app

- `[~]` All source/assets are clean by inspection, but ownership, the exact MIT
  copyright holder, and app-icon permission still require the owner’s
  confirmation.
- `[~]` No current-tree secrets, certificates, real workout exports, or copied
  map data were found; there is no prior commit history to certify.
- `[x]` MapKit runtime use is documented and the app has no video export path or
  rendered Apple Maps media.

## Commands and checks run

- `rg --files --hidden` and targeted `rg` scans for credentials, personal paths,
  dependencies, map data, and media.
- `find`/`file`/`sips` review of repository files and the app icon.
- `plutil` review of `Info.plist` and HealthKit entitlements.
- `xcodebuild ... build` — **passed** on Xcode 26.6 / iOS 26.5 simulator SDK.
- `xcodebuild test` — 14 unit tests passed; 4 of 5 UI tests passed in the full
  run, with `testFullWorkoutFlow` failing once while waiting for the play
  button. The same UI test passed when rerun in isolation; treat this as a
  simulator/test-order timing flake and rerun the full suite before pushing.
- `git status` — empty repository on `main`; no commits/history are present.

## Remaining actions before the first public push

1. Confirm the exact copyright holder name and authorship/permissions for all
   source and the app icon.
2. Add the standard MIT `LICENSE` file using that confirmed holder name.
3. Do a device check of MapKit attribution and the HealthKit permission flow.
4. If screenshots are added later, preserve MapKit attribution and review the
   applicable Apple Maps terms before publishing them.
5. Inspect the staged file list, create the first intentional commit, review it
   once more, then enable the GitHub security settings listed above.

## Reference material

- [Apple: Protecting user privacy](https://developer.apple.com/documentation/healthkit/protecting-user-privacy)
- [Apple: Authorizing access to health data](https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data)
- [Apple Developer Program License Agreement](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/)
- [GitHub: Quickstart for securing a repository](https://docs.github.com/en/code-security/getting-started/quickstart-for-securing-your-repository)
