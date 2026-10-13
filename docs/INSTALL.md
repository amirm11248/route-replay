# Install Route Replay on iPhone

**Version 1.0.0 · iPhone · iOS 17+**

Download the **[Route Replay unsigned IPA](https://github.com/amirm11248/route-replay/releases/download/v1.0.0/RouteReplay-1.0.0-unsigned.ipa)**. Because this file is unsigned, it cannot be opened directly from the iPhone's Files app to install it.

You can try installing the IPA with **Sideloadly** or **AltStore Classic**. Both support Windows and macOS and sign the IPA using an Apple Account. **Important:** Route Replay needs the **HealthKit** entitlement to read Apple Health workouts. These sideloading methods have **not yet been verified with Route Replay v1.0.0 on a physical iPhone**. An app that installs but cannot request Apple Health permission may have been signed without HealthKit.

## Method 1 — Sideloadly (IPA)

**You need:** an iPhone running iOS 17+, a Mac or Windows computer, an Apple Account, and a USB cable for the first installation.

1. Download [Sideloadly](https://sideloadly.io/) for your computer and install it.
2. Download the [Route Replay IPA](https://github.com/amirm11248/route-replay/releases/download/v1.0.0/RouteReplay-1.0.0-unsigned.ipa).
3. Connect your unlocked iPhone to the computer with a cable. Tap **Trust** if your iPhone prompts you. On Windows, follow Sideloadly's instructions to install the required Apple device software (its site recommends the non-Microsoft-Store iTunes and iCloud installers).
4. Open **Sideloadly**. Drag the downloaded `.ipa` file into the app and select your iPhone as the target device.
5. Enter your **own Apple Account** in Sideloadly, then click **Start**. Follow the Apple sign-in and two-factor authentication prompts when asked.
6. Once installed, on your iPhone enable **Settings → Privacy & Security → Developer Mode** if required (it may restart). If iOS asks you to trust the developer, check **Settings → General → VPN & Device Management** and follow the trust prompt.
7. Open **Route Replay** and tap **Allow & Sync Workouts**. If the Apple Health permission screen appears, grant the read access you want to provide.

With a free Apple Account, sideloaded apps normally expire after **7 days**. Sideloadly offers automatic refreshing, but your computer must be available for refreshes. See [Sideloadly's official guide and FAQ](https://sideloadly.io/).

**HealthKit caution:** Installing successfully does **not** guarantee Apple Health access. If the Health authorization prompt does not appear, the signing profile or resulting signature may not authorize the `com.apple.developer.healthkit` entitlement. A different one-click installer cannot fix a missing Apple-approved entitlement.

## Method 2 — AltStore Classic (IPA alternative)

**Use AltStore Classic, not AltStore PAL.** AltStore PAL is a separate marketplace and **does not install arbitrary `.ipa` files**. [AltStore's comparison](https://github.com/altstoreio/FAQ/blob/main/altstore-pal/what-is-altstore-pal.md)

1. Install **AltServer** from [AltStore's official website](https://altstore.io/) on your Mac or Windows PC. Follow its official [macOS](https://faq.altstore.io/altstore-classic/how-to-install-altstore-macos) or [Windows](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows) setup guide to install **AltStore Classic** on the iPhone.
2. Download the [Route Replay IPA](https://github.com/amirm11248/route-replay/releases/download/v1.0.0/RouteReplay-1.0.0-unsigned.ipa) and save it to **Files** on your iPhone (transfer it there if you downloaded it on your computer).
3. Keep AltServer running and your iPhone connected over USB or on the same Wi-Fi network as the computer.
4. Open **AltStore Classic → My Apps**, tap **+**, and select the downloaded Route Replay `.ipa` from Files. Follow the sign-in or confirmation prompts to install.
5. Enable **Developer Mode** and trust your signing identity if iOS requires it. Then launch Route Replay and check whether Apple Health permissions work.

AltStore Classic apps signed using a free Apple Account generally need refreshing every **7 days**, and Apple's free-account limits apply. AltServer needs to be running and reachable when refreshing. See [AltStore's setup and refresh instructions](https://faq.altstore.io/altstore-classic/altserver).

**HealthKit caution:** As with Sideloadly, AltStore Classic may install the IPA without preserving/authorizing the entitlement Route Replay needs. Apple Health access through this method has **not** been verified for this release.

## Method 3 — Build and install with Xcode (recommended if HealthKit signing fails)

If you have a Mac, installing directly from the source code gives Xcode control of signing and capabilities, and avoids manually re-signing an IPA.

1. Install [Xcode](https://developer.apple.com/xcode/) and [XcodeGen](https://github.com/yonaskolb/XcodeGen). Add your Apple Account in **Xcode → Settings → Accounts**.
2. Open Terminal:

   ```bash
   git clone https://github.com/amirm11248/route-replay.git
   cd route-replay
   brew install xcodegen # skip if installed
   xcodegen generate
   open RouteReplay.xcodeproj
   ```

3. In Xcode select the **RouteReplay** app target → **Signing & Capabilities**. Turn on **Automatically manage signing**, select your team, and set a **unique Bundle Identifier**.
4. Keep the **HealthKit** capability enabled. Your signing team and provisioning profile must authorize that capability; Xcode will report a signing error if they do not.
5. Connect and unlock your iPhone, select it as the run destination, and press **Run (⌘R)**. Complete any Developer Mode prompts, then grant read access in Apple Health.

[Apple's HealthKit configuration instructions](https://developer.apple.com/documentation/xcode/configuring-healthkit-access) · [Apple's provisioning/entitlement explanation](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles)

## Troubleshooting

- **Installation fails / app won't open:** Make sure the iPhone is unlocked and trusted, Developer Mode is enabled if requested, and the Apple signing profile is valid and not expired.
- **No Apple Health permission / no workouts:** Check that the **signed app** includes `com.apple.developer.healthkit` and the provisioning profile explicitly authorizes it. If unsure, build with Xcode and inspect the signing errors. Merely putting an entitlements file beside an IPA does not enable HealthKit.
- **Free Apple Account:** Sideloaded apps usually expire after seven days and must be refreshed. Some Apple capabilities may not be available to every signing team.
- **No 3D imagery:** Apple Maps coverage varies by location.

Route Replay processes imported workouts locally. See the project's [privacy notice](../PRIVACY.md). Only download tools from their official websites, and never send your Apple Account password, certificates, or personal Health data to the project maintainer.
