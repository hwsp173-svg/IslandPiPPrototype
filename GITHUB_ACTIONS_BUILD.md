# GitHub Actions Build Guide

This project builds on GitHub Actions using a `macos-26` runner with Xcode 26.6 and the iOS 26 SDK. **No Mac, Xcode installation, or Apple developer account is needed on your Windows PC** — the build runs entirely in GitHub's cloud.

## Pipeline Overview

```
Windows (edit code)
  → git push to GitHub
  → GitHub Actions: macos-26 runner + Xcode 26.6
  → xcodebuild archive (arm64, unsigned)
  → Package as .ipa
  → Download artifact to Windows
  → Sideloadly signs + installs
  → iPhone 12
```

## 1. Push the Project to GitHub

If the repository does not exist yet:

1. Go to [github.com/new](https://github.com/new) and create a new **private** repository (e.g., `IslandPiPPrototype`). Do **not** initialize with a README.
2. In PowerShell on your Windows PC, navigate to the project directory and run:

```powershell
cd "C:\Users\vsl\Documents\Codex\2026-08-17\dynamic-island-pip-prototype-for-iphone\outputs\IslandPiPPrototype"
git init
git add .
git commit -m "Initial commit: IslandPiPPrototype with CI workflow"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/IslandPiPPrototype.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## 2. Trigger the Build

The workflow triggers automatically when you push to `main`. You can also trigger it manually:

1. Go to your repository on GitHub.
2. Click the **Actions** tab.
3. Select the **Build iOS (Unsigned IPA)** workflow.
4. Click **Run workflow** → **Run workflow**.

## 3. Monitor the Build

The workflow takes roughly 5–15 minutes. It will:

1. Check out your code on a `macos-26` runner.
2. Detect and select Xcode 26.6 (or newest available 26.x).
3. Print the exact Xcode version, iOS SDK version, and Swift version.
4. Verify the project, scheme, and build settings.
5. Archive the app for `generic/platform=iOS` (arm64 physical device) **without code signing**.
6. Package the `.app` bundle into a standard `Payload/` IPA structure.
7. Upload the IPA as a downloadable artifact.

If the build fails, it also uploads `build.log` as an artifact so you can inspect the full Xcode compiler output.

## 4. Download the IPA

1. Go to the completed workflow run on GitHub (Actions tab → click the run).
2. Scroll to the **Artifacts** section at the bottom.
3. Download **IslandPiPPrototype-unsigned**.
4. Extract the ZIP. Inside is `IslandPiPPrototype.ipa`.

## 5. Install with Sideloadly on Windows

### Prerequisites

- **Sideloadly** installed from [sideloadly.io](https://sideloadly.io/)
- **Apple device drivers**: Sideloadly will prompt you to install iTunes or Apple Devices if needed
- **Apple ID**: A free Apple ID is sufficient (7-day signing expiry); a paid Developer account gives 365-day signing
- **iPhone 12** connected via USB cable

### Installation Steps

1. **Connect your iPhone 12** to the Windows PC via USB.
2. Unlock the phone. If prompted, tap **Trust** on the iPhone and enter your passcode.
3. **Open Sideloadly** on Windows.
4. In the **iDevice** dropdown at the top, select your iPhone 12.
5. Drag the `IslandPiPPrototype.ipa` onto Sideloadly, or click the IPA icon to browse and select it.
6. Enter your **Apple ID** in the Apple Account field.
7. Click **Start**.
8. Enter your Apple ID password when prompted. If you have 2FA enabled, you will also need to enter the verification code.
9. Wait for Sideloadly to sign and install the app. This typically takes 1–2 minutes.

### After Installation

1. On the iPhone, the app icon appears on the Home Screen but may show as greyed out.
2. Go to **Settings → General → VPN & Device Management** (on older iOS: **Profiles & Device Management**).
3. Under **Developer App**, tap the profile matching your Apple ID.
4. Tap **Trust "[your email]"** and confirm.
5. Return to the Home Screen and tap **Island PiP** to launch.

> **Free Apple ID note**: Apps signed with a free Apple ID expire after 7 days. You can re-sign and reinstall through Sideloadly at any time. You are limited to 3 active app IDs at a time with a free account.

## Build Configuration Reference

| Setting | Value |
|---|---|
| Runner | `macos-26` |
| Xcode | 26.6 (preferred) or newest 26.x available |
| iOS SDK | iOS 26 (from Xcode 26) |
| Configuration | Release |
| Architecture | arm64 |
| Destination | `generic/platform=iOS` (physical device) |
| Deployment target | iOS 17.0 |
| Device family | iPhone only (`TARGETED_DEVICE_FAMILY = 1`) |
| Code signing | Disabled (`CODE_SIGNING_ALLOWED=NO`) |
| Bundle ID | `com.example.IslandPiPPrototype` |
| Background modes | Audio (for PiP) |

## Troubleshooting

### Build fails: "No Xcode 26.x found"

The `macos-26` runner should have Xcode 26.6 preinstalled as the default. If GitHub updates the runner image, check the [runner-images repository](https://github.com/actions/runner-images) for current availability.

### Build fails: Swift compilation error

Download the `build-logs` artifact from the failed run. It contains the full `xcodebuild` output. Common fixes:
- API deprecated in newer Swift: check the error line and update the Swift source.
- Missing file: ensure all files are committed to git (`git status`).

### Sideloadly: "Could not connect to device"

- Make sure iTunes or Apple Devices is installed on Windows.
- Unlock the iPhone before connecting.
- Try a different USB cable or port.
- On the iPhone, go to **Settings → Privacy & Security → Developer Mode** and enable it if prompted.

### App crashes on launch

- Ensure Developer Mode is enabled on iPhone (Settings → Privacy & Security → Developer Mode).
- Ensure the developer profile is trusted (Settings → General → VPN & Device Management).
- If using iOS 26, Developer Mode may need to be toggled on first via Settings.

### PiP does not activate

- PiP requires a physical iPhone — it does not work reliably on simulators.
- Background audio mode must be enabled (it is in this project's Info.plist).
- The app must have been launched at least once and the video surface must be visible before PiP can start.
- iOS controls whether PiP is allowed based on system state.

## What This Workflow Does NOT Do

- ❌ Sign the app (Sideloadly does this)
- ❌ Store any Apple credentials in GitHub
- ❌ Upload to the App Store
- ❌ Build for simulator
- ❌ Require a Mac on your end
- ❌ Require Xcode on Windows
