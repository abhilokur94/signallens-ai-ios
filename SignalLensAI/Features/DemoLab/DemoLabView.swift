import SwiftUI

struct DemoScenario: Identifiable, Sendable {
    let id: UUID
    let title: String
    let detail: String
    let symbol: String
    let snapshots: [NetworkSnapshot]

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        symbol: String,
        snapshots: [NetworkSnapshot]
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.symbol = symbol
        self.snapshots = snapshots
    }
}

struct DemoLabView: View {
    @Environment(AppModel.self) private var model

    private var scenarios: [DemoScenario] {
        [
            wifiToCellularScenario,
            offlineRecoveryScenario,
            constrainedPathScenario
        ]
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(scenarios) { scenario in
                        scenarioButton(for: scenario)
                    }
                } header: {
                    Text("Privacy-safe simulations")
                } footer: {
                    Text(
                        """
                        Demo samples traverse the same analysis pipeline \
                        and remain explicitly marked SIMULATED.
                        """
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(SLColor.ink)
            .navigationTitle("Demo Lab")
        }
    }

    private func scenarioButton(
        for scenario: DemoScenario
    ) -> some View {
        Button {
            run(scenario)
        } label: {
            HStack(spacing: 14) {
                scenarioIcon(for: scenario)

                VStack(alignment: .leading, spacing: 5) {
                    Text(scenario.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(scenario.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)

                Image(systemName: "play.fill")
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Run \(scenario.title)")
        .accessibilityHint(scenario.detail)
        .listRowBackground(SLColor.panel)
    }

    private func scenarioIcon(
        for scenario: DemoScenario
    ) -> some View {
        Image(systemName: scenario.symbol)
            .font(.title2)
            .foregroundStyle(.orange)
            .frame(width: 38, height: 38)
            .background(
                Color.orange.opacity(0.14),
                in: RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous
                )
            )
            .accessibilityHidden(true)
    }

    private func run(
        _ scenario: DemoScenario
    ) {
        model.inject(scenario.snapshots)
        model.selectedTab = .pulse
    }

    private var wifiToCellularScenario: DemoScenario {
        let startingTime = Date.now

        return DemoScenario(
            title: "Wi-Fi to cellular handover",
            detail: "Exercises transport-transition detection.",
            symbol: "arrow.triangle.swap",
            snapshots: [
                NetworkSnapshot(
                    timestamp: startingTime,
                    transport: .wifi,
                    isConnected: true,
                    provenance: .simulated
                ),
                NetworkSnapshot(
                    timestamp: startingTime.addingTimeInterval(1),
                    transport: .cellular,
                    isConnected: true,
                    isExpensive: true,
                    provenance: .simulated
                )
            ]
        )
    }

    private var offlineRecoveryScenario: DemoScenario {
        let startingTime = Date.now

        return DemoScenario(
            title: "Offline and recovery",
            detail: "Exercises the offline and recovery experience.",
            symbol: "bolt.slash",
            snapshots: [
                NetworkSnapshot(
                    timestamp: startingTime,
                    transport: .wifi,
                    isConnected: true,
                    provenance: .simulated
                ),
                NetworkSnapshot(
                    timestamp: startingTime.addingTimeInterval(1),
                    transport: .none,
                    isConnected: false,
                    provenance: .simulated
                ),
                NetworkSnapshot(
                    timestamp: startingTime.addingTimeInterval(2),
                    transport: .cellular,
                    isConnected: true,
                    isExpensive: true,
                    provenance: .simulated
                )
            ]
        )
    }

    private var constrainedPathScenario: DemoScenario {
        DemoScenario(
            title: "Constrained path",
            detail: "Exercises Low Data Mode-aware presentation.",
            symbol: "gauge.with.dots.needle.33percent",
            snapshots: [
                NetworkSnapshot(
                    transport: .cellular,
                    isConnected: true,
                    isExpensive: true,
                    isConstrained: true,
                    provenance: .simulated
                )
            ]
        )
    }
}
