# Island PiP Prototype

A public-API SwiftUI prototype for an iPhone 12. It provides a polished in-app Dynamic-Island-inspired surface and an experimental AVKit Picture in Picture path. The PiP path is deliberately separate: iOS owns its window, controls, placement, size, and background behavior.

## Requirements

- Xcode 15.4 or newer
- iOS 17.0 deployment target
- A signed physical iPhone for meaningful PiP validation

## Open and run

1. Open `IslandPiPPrototype.xcodeproj` in Xcode.
2. Select your Apple Development team in the **IslandPiPPrototype** target's Signing & Capabilities tab.
3. Connect an iPhone 12, select it as the run destination, and press Run.
4. Use the PiP control in the app and verify behavior on the physical device. iOS, not the app, decides whether PiP is possible in the current media context.

For a free Apple ID, sign in to Xcode, select that Personal Team, trust the developer certificate on the phone if asked, and run directly from Xcode. No special entitlement, profile, or sideloading configuration is required beyond normal development signing.

## Commands

```sh
xcodebuild -project IslandPiPPrototype.xcodeproj -scheme IslandPiPPrototype -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild -project IslandPiPPrototype.xcodeproj -scheme IslandPiPPrototype -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## PiP limitations (tested/confirm on physical hardware)

- PiP is a system media window, not a transparent overlay. Standard PiP video has an opaque rectangular video surface; transparency is not a reliable way to reveal another app.
- iOS decides minimum size, placement, resizing and drag behavior. An app cannot attach PiP to the notch or place it near the status area.
- The system may show transport/close/return-to-app controls. This project requests that playback controls be hidden where the public API permits, but iOS retains final control.
- PiP can continue while this app backgrounds only while its media session and device policy support it. It is not a general always-on-top window.
- The project uses a tiny generated 160×90, 1 fps looping H.264 surface to keep the PiP experiment lightweight. The rich island UI stays in-app because SwiftUI cannot be placed inside a normal AVPlayer PiP surface.
- Exact minimum PiP dimensions, added controls, and background behavior vary by iOS release and must be verified on an actual iPhone. Simulator results are not authoritative.

## Architecture

- `App` lifecycle and dependencies
- `Models` state and settings
- `Island` controller, animator, and SwiftUI surface
- `Demo` state factory and timer behavior
- `PiP` AVKit bridge and lightweight asset factory
- `UI` settings/demo screens
- `Services` haptics and diagnostics

The app never uses private APIs, overlays other apps, injection, jailbreak mechanisms, or a custom entitlements file. For Windows/Sideloadly instructions, read `BUILD_FOR_WINDOWS_SIDELOADLY.md`.
