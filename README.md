# SignalLens AI for iOS

A privacy-first, native iOS connectivity intelligence application. SignalLens turns Apple Network framework observations and app-initiated diagnostics into evidence-linked, human-readable connectivity insights.

## Tools, Authentication and Use

- Swift 6, SwiftUI, native iOS lifecycle and adaptive UI
- Swift Concurrency through `AsyncStream`, actors, `Task`, and async URLSession
- Security and privacy boundaries by construction
- CryptoKit AES-GCM encryption and a device-only Keychain key
- Cellular-aware path observation without claiming prohibited carrier-core visibility
- Deterministic tests and a Demo Lab that runs through the production analysis pipeline
- Full feature lifecycle artifacts: architecture, threat model, privacy notes, CI, tests, and release checklist

## Architecture

```text
SwiftUI views
  -> @Observable AppModel / unidirectional actions
  -> domain services and IncidentEngine
  -> protocols
  -> NWPathMonitor, URLSession, Keychain, CryptoKit
  -> in-memory local-first store (replaceable persistence boundary)
```

The repository avoids third-party runtime dependencies. XcodeGen is used only to generate the `.xcodeproj` from a reviewable YAML specification.

## Requirements

- macOS with Xcode 16 or newer
- iOS 17 or newer deployment target
- An Apple ID configured in Xcode for physical-device signing
- Homebrew and XcodeGen, or create a project manually using the supplied source tree

## Generate and open in Xcode

```bash
brew install xcodegen
cd SignalLensAI-iOS
xcodegen generate
open SignalLensAI.xcodeproj
```

In Xcode:

1. Select the **SignalLensAI** project and application target.
2. Open **Signing & Capabilities**.
3. Select your Apple Development team.
4. If necessary, change `com.abhisheklokur.SignalLensAI` to a bundle identifier unique to your account.
5. Select an iPhone simulator or connected iPhone.
6. Press **Command-R**.
7. Press **Command-U** to run the unit tests.

## Run on a physical iPhone

1. Connect the iPhone by cable and trust the Mac.
2. Enable Developer Mode on the iPhone if iOS asks for it.
3. Select the phone in Xcode's run-destination menu.
4. Confirm automatic signing is enabled and your development team is selected.
5. Build and run with **Command-R**.

A physical device is recommended for meaningful Wi-Fi/cellular path transitions. Demo Lab works in both Simulator and device builds.

## Implemented vertical slices

- Live Network Pulse driven by `NWPathMonitor`
- Wi-Fi, cellular, wired, constrained, expensive, IPv4, and IPv6 path presentation
- Async privacy-safe HTTP quick check
- Deterministic incident analysis with evidence and confidence
- Connectivity timeline
- Incident detail and bounded explanation UX
- Demo Lab with handover, offline recovery, and constrained-path scenarios
- Privacy Center with delete-all control
- AES-GCM report-vault service backed by a device-only Keychain key
- Unit tests for incident behavior

## Known platform boundary

SignalLens is not a packet sniffer and does not inspect voice, SMS, browsing payloads, IMS state, RAN counters, packet-core state, or private carrier systems. `NWPathMonitor` reports the network path visible to the application. Active checks describe only the app-to-endpoint experience.

## Production evolution

- Replace the in-memory `TelemetryStore` with a SwiftData or Core Data actor-backed implementation.
- Add MetricKit diagnostics and os.Logger signposts.
- Add BGTaskScheduler-based retention cleanup where justified.
- Add encrypted report export and explicit redaction preview.
- Add UI, screenshot, accessibility, and performance tests.
- Add StoreKit-backed plan surfaces only if a real product requires them.
- Complete privacy manifest, App Store metadata, export compliance review, and external security review.

## GitHub publish

```bash
git init
git add .
git commit -m "Build SignalLens AI iOS foundation"
git branch -M main
git remote add origin git@github.com:abhilokur94/signallens-ai-ios.git
git push -u origin main
```

## License

MIT for the portfolio code. Apple platform frameworks remain subject to Apple's terms.
