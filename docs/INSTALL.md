# Install Route Replay on iPhone

**iOS 17+ · iPhone · Version 1.0.0**

Route Replay is not on the App Store. Its [release download](https://github.com/amirm11248/route-replay/releases/latest) is an **unsigned IPA**, not a tap-to-install app. iOS needs a valid code signature and provisioning profile before it can install the app.

> **Recommended for most people with a Mac:** use Xcode below. It handles signing automatically. You do **not** need to download or manually sign the IPA if you build from source.

## Option 1 — Install with Xcode (recommended)

**You need:** a Mac, [Xcode](https://developer.apple.com/xcode/), an Apple Account, [XcodeGen](https://github.com/yonaskolb/XcodeGen), and an iPhone running iOS 17 or later.

1. In Xcode, add your Apple Account under **Xcode → Settings → Accounts**.
2. Open Terminal and run:

   ```bash
   git clone https://github.com/amirm11248/route-replay.git
   cd route-replay
   brew install xcodegen
   xcodegen generate
   open RouteReplay.xcodeproj
   ```

   If XcodeGen is already installed, skip the `brew install` command.
3. In Xcode, select the **RouteReplay** project, then the **RouteReplay** app target → **Signing & Capabilities**. Enable **Automatically manage signing**, choose your **Team**, and give the app a **unique bundle identifier** (for example, `com.yourname.RouteReplay`). Make sure **HealthKit** remains enabled.
4. Connect and unlock your iPhone, trust your Mac if asked, choose your iPhone as the run destination, then press **Run (⌘R)**. Follow any instructions to enable Developer Mode.
5. In Route Replay, tap **Allow & Sync Workouts** and grant the requested **read** access in Apple Health.

Xcode creates the development signing assets and installs the app for you. A free Personal Team can have limitations, including seven-day provisioning expiration; if Xcode says a capability or profile is unavailable for your team, its signing error is authoritative. [Apple: run an app on your device](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices) · [Apple: personal-team limits](https://developer.apple.com/help/account/basics/about-your-developer-account/)

## Option 2 — Sign the downloaded IPA (advanced)

Choose this only if you **already have** an iOS signing certificate and a device provisioning profile that explicitly authorize **HealthKit**. Merely downloading the IPA, or adding an entitlements file by itself, is not enough.

1. Download [RouteReplay-1.0.0-unsigned.ipa](https://github.com/amirm11248/route-replay/releases/download/v1.0.0/RouteReplay-1.0.0-unsigned.ipa).
2. Have an **explicit App ID**, a signing certificate with its private key, and a matching **development/ad hoc provisioning profile** for the device you want to install on. HealthKit must be enabled for that App ID **and authorized by the profile**. If you don't already have these, use Option 1 instead. [Apple: HealthKit setup](https://developer.apple.com/documentation/xcode/configuring-healthkit-access)
3. On a Mac, open [iOS App Signer](https://github.com/DanTheMan827/ios-app-signer). Select the unsigned IPA, the signing certificate, and the correct provisioning profile. Set the app identifier to the explicit identifier authorized by your profile if it differs from the packaged app's ID.
4. Export the **signed IPA**. Check that its signature and embedded profile still include the **HealthKit** entitlement (`com.apple.developer.healthkit`). If they do not, don't expect workout import to work. [Apple: how provisioning entitlements work](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles)
5. Connect the iPhone to your Mac. In Xcode, open **Window → Devices and Simulators → Devices**, select your iPhone, click **+** under Installed Apps, and choose the **signed** IPA. Enable Developer Mode if needed, then launch and grant Apple Health read access. [Apple: install IPA files](https://help.apple.com/xcode/mac/current/en.lproj/devade83d1d7.html)

**Important:** Third-party one-click sideloaders can replace or omit required entitlements. We have **not verified** the v1.0.0 unsigned release using a third-party signing service on a physical device. Never upload your Apple signing certificates or Apple Account credentials to an untrusted service.

## Troubleshooting

- **“Untrusted Developer”, Developer Mode, or installation failure:** Confirm Developer Mode when required, verify that the provisioning profile includes this specific iPhone, and check the certificate/profile expiration.
- **No workouts or Health permission:** The signing profile may not authorize HealthKit. Verify both the signed app's entitlement and Apple Health permissions. A successful installation alone is not proof that HealthKit is working.
- **No matching provisioning profile:** Use Option 1. iOS App Signer does not automatically create the required HealthKit-enabled profile for you.
- **Apple Account / free signing:** Free development profiles expire and may require periodic reinstallation; some signing capabilities depend on team membership.
- **3D imagery unavailable:** 3D/satellite coverage varies by location in Apple Maps.

The app reads workout data on your device. See [Privacy](../PRIVACY.md). This installation guide does not request Apple Account credentials, signing keys, or Health data from you.
