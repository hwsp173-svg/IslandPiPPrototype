# IslandBrowser

IslandBrowser is a polished iPhone browser built with SwiftUI and `WKWebView`. It includes a public-API in-app Dynamic Island simulation that remains visible above the browser while keeping webpage interaction normal everywhere else.

## Highlights

- Persistent `WKWebsiteDataStore.default()` cookies and website data
- HTTPS navigation, URL entry, Google search, JavaScript, forms, login pages, scrolling, back/forward, reload, share, and progress state
- Keyboard-safe address bar and browser toolbar
- True fullscreen web view with the browser toolbar removed
- Compact and expanded Dynamic Island surfaces with music, timer, charging, download, notification, and custom modes
- UIKit passthrough hit testing so only visible island controls intercept touches
- iOS 17.0 deployment target, iPhone-only, arm64

## Build

Open `IslandBrowser.xcodeproj` in Xcode and select the shared `IslandBrowser` scheme. The unsigned GitHub Actions workflow builds a Release archive for `generic/platform=iOS`, packages `IslandBrowser.ipa`, and uploads the `IslandBrowser-unsigned` artifact.

The app intentionally uses no PiP, AVKit, AVFoundation, background audio, private APIs, or access to the system Dynamic Island.
