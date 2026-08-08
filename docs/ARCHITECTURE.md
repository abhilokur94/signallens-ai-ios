# Architecture

## Principles

1. Local-first by default.
2. Evidence before explanation.
3. Observed, derived, and simulated provenance is never erased.
4. Apple framework adapters sit behind protocols.
5. Swift Concurrency owns asynchronous boundaries.
6. SwiftUI renders immutable domain outcomes through a MainActor model.
7. Demo scenarios use the same ingestion and incident code as live observations.

## Layers

### Presentation

SwiftUI feature views read `AppModel` through the environment. UI mutation occurs on the main actor. Feature views never manipulate `NWPathMonitor`, URLSession, Keychain, or CryptoKit directly.

### Domain

`IncidentEngine` is a pure value type and can be exhaustively tested. It turns transitions into evidence-linked incidents and computes the current health classification.

### Platform adapters

`AppleNetworkPathMonitor` converts `NWPath` callbacks into `AsyncStream<NetworkSnapshot>`. `QuickCheckService` is an actor around URLSession. `SecureReportVault` is an actor around CryptoKit and Keychain.

### Persistence boundary

`TelemetryStore` is an observable in-memory implementation for the runnable foundation. Its API isolates the rest of the app from persistence details, allowing SwiftData or Core Data to replace it without rewriting features.

## Threat model summary

Protected assets include telemetry, incident notes, reports, and local cryptographic keys. Main threats include unintended export, sensitive identifiers in logs, unauthorized local access, over-claiming telemetry visibility, and model explanations stated as fact. Controls include no payload collection, device-only Keychain accessibility, AES-GCM, provenance labels, bounded explanations, explicit delete controls, and no analytics SDK.
