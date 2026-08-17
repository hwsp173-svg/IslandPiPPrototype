# Build for Windows + Sideloadly

## What this project is

This is a normal Swift/SwiftUI iOS application. It targets iOS 17.0 and physical iPhone hardware (`arm64`). It has no Swift Package dependencies, CocoaPods, network permissions, receipt checks, custom entitlements, App Store-only services, or private framework references.

Windows cannot compile an iOS app or create a signed IPA because Xcode and the iOS SDK are macOS-only. Sideloadly signs and installs an IPA; it does not replace Xcode’s compiler or iOS SDK.

## Configuration verified in the project files

| Item | Value |
| --- | --- |
| Deployment target | iOS 17.0 |
| Device family | iPhone (`TARGETED_DEVICE_FAMILY = 1`) |
| Device architecture | `arm64` |
| Bundle ID | `com.example.IslandPiPPrototype` — change before signing |
| Capabilities | Background Modes: Audio, AirPlay, and Picture in Picture (`UIBackgroundModes = audio`) |
| Entitlements file | None; none is needed |
| Third-party dependencies | None |

iPhone 12 is arm64 and supports iOS 17, so no Dynamic-Island-specific API is used. The app is portrait-only and its visible UI uses SwiftUI safe-area-aware layout. It does not access camera, microphone, location, contacts, photos, Bluetooth, or the network; therefore no privacy usage descriptions are appropriate or required.

## Build an IPA on macOS

1. Transfer this complete project folder to a Mac with Xcode 15.4+ installed.
2. Open `IslandPiPPrototype.xcodeproj`.
3. Select the **IslandPiPPrototype** app target, then **Signing & Capabilities**.
4. Set a unique bundle identifier you control, for example `com.yourname.IslandPiPPrototype`.
5. Choose your Apple Development team. Do not add capabilities beyond the existing Background Modes declaration. In Background Modes, ensure **Audio, AirPlay, and Picture in Picture** is checked.
6. Select **Any iOS Device (arm64)** and choose **Product → Clean Build Folder**, then **Product → Archive**.
7. In Organizer, select the archive, choose **Distribute App → Development**, choose your team, then export the IPA to a folder you can transfer to Windows.

For command-line validation before archiving:

```sh
xcodebuild -project IslandPiPPrototype.xcodeproj -scheme IslandPiPPrototype -destination 'generic/platform=iOS' build
xcodebuild -project IslandPiPPrototype.xcodeproj -scheme IslandPiPPrototype -destination 'platform=iOS Simulator,name=iPhone 15' test
```

Do not represent the unsigned project folder as an IPA. The macOS build step is required.

## Install using Sideloadly on Windows

1. Install the normal current Sideloadly release and the Apple device drivers/components it requests.
2. Connect the iPhone 12 by USB, unlock it, and tap **Trust** if asked.
3. Copy the exported development IPA from the Mac to the Windows PC.
4. Open Sideloadly, select the connected iPhone 12, choose the IPA, and sign in with the Apple ID you use for normal sideloading.
5. Start the install. Sideloadly performs its normal signing process; this project does not attempt to alter that process.
6. On the iPhone, go to **Settings → General → VPN & Device Management**, select the developer profile, and trust it if iOS asks. Open the app.

Free provisioning is subject to Apple’s normal limits and expiry. Reinstall/re-sign through Sideloadly as required by that account type.

## Test first on the iPhone 12

1. Launch the app and confirm the in-app island is centered below the notch and does not overlap status content.
2. Exercise every demo, including expanding, collapsing, swipe dismissal, custom content, haptics, and Reduce Motion.
3. Start PiP, leave the app, and confirm the delegate diagnostics change state.
4. Open another app: PiP, if accepted by iOS, is a system-managed movable/resizable media window while the other app is foreground.
5. Verify behavior after locking/unlocking, an audio interruption, and returning to the app.

## PiP reality on iPhone 12

AVKit PiP accepts video content from an `AVPlayerLayer` (used here) or a sample-buffer display layer. It is a floating, resizable system media window, not an app-controlled overlay. The system chooses the practical minimum size, preserves the video’s aspect ratio, determines placement, and lets the person move/resize it. There is no supported API to measure or set a fixed minimum PiP size, attach it to the notch, set its coordinates, make the video surface transparently reveal another app, remove all system controls, or turn it into a Dynamic Island replacement.

This prototype intentionally supplies a generated 160×90 opaque black H.264 clip at 1 fps and loops it. It has no shipped video resource, network transfer, image sequence, polling loop, or high-frequency rendering. The rich Dynamic-Island-inspired experience is the in-app SwiftUI surface. PiP can remain active when this app backgrounds only while iOS accepts the media session and PiP context; it may stop or be suspended by the system. Exact size, controls, and continuation behavior must be confirmed on the physical device and iOS version.

Apple’s public documentation confirms that PiP uses a floating resizable window and requires the Audio, AirPlay, and Picture in Picture background mode: [AVPictureInPictureController](https://developer.apple.com/documentation/AVKit/AVPictureInPictureController) and [Configuring media playback](https://developer.apple.com/documentation/AVFoundation/configuring-your-app-for-media-playback).
