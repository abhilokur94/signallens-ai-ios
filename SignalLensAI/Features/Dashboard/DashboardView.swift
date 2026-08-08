import SwiftUI

struct DashboardView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    pulse
                    metrics
                    quickCheck
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        SLColor.ink,
                        Color(
                            red: 0.09,
                            green: 0.08,
                            blue: 0.20
                        )
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("SignalLens AI")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(SLColor.cyan)
                        .accessibilityLabel("Privacy-first local monitoring")
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("NETWORK PULSE")
                    .font(.caption.bold())
                    .tracking(2)
                    .foregroundStyle(SLColor.cyan)

                Text(model.health.rawValue)
                    .font(
                        .system(
                            size: 40,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                Text(summary)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ProvenanceBadge(
                value: model.currentSnapshot?.provenance ?? .observed
            )
        }
    }

    private var summary: String {
        guard let snapshot = model.currentSnapshot else {
            return "Waiting for the first iOS path update."
        }

        if snapshot.isConnected {
            return "\(snapshot.transport.rawValue) path is available."
        } else {
            return "No usable network path is available."
        }
    }

    private var pulse: some View {
        GlassCard {
            VStack(spacing: 16) {
                TimelineView.PulseShape(
                    samples: model.health == .excellent ? 8 : 4
                )
                .stroke(
                    healthColor,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(height: 110)
                .animation(
                    .easeInOut,
                    value: model.health
                )

                HStack {
                    Label(
                        currentTransportName,
                        systemImage: currentTransportSymbol
                    )

                    Spacer()

                    Text(
                        model.currentSnapshot?.isExpensive == true
                            ? "Metered"
                            : "Standard"
                    )
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var healthColor: Color {
        switch model.health {
        case .excellent:
            return SLColor.cyan
        case .stable:
            return .green
        case .degraded:
            return .orange
        case .unstable:
            return .red
        case .offline:
            return .gray
        }
    }

    private var currentTransportName: String {
        model.currentSnapshot?.transport.rawValue ?? "Unknown"
    }

    private var currentTransportSymbol: String {
        guard let transport = model.currentSnapshot?.transport else {
            return "questionmark.circle"
        }

        switch transport {
        case .wifi:
            return "wifi"
        case .cellular:
            return "antenna.radiowaves.left.and.right"
        case .wired:
            return "cable.connector"
        case .other:
            return "network"
        case .none:
            return "network.slash"
        }
    }

    private var metrics: some View {
        HStack(spacing: 10) {
            metric(
                title: "IPv4",
                value: model.currentSnapshot?.supportsIPv4 == true
                    ? "Yes"
                    : "No"
            )

            metric(
                title: "IPv6",
                value: model.currentSnapshot?.supportsIPv6 == true
                    ? "Yes"
                    : "No"
            )

            metric(
                title: "Latency",
                value: latencyDescription
            )
        }
    }

    private var latencyDescription: String {
        guard let latency = model.store.probes.first?.latencyMS else {
            return "Not run"
        }

        return "\(Int(latency.rounded())) ms"
    }

    private func metric(
        title: String,
        value: String
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    private var quickCheck: some View {
        Button(
            action: {
                model.runQuickCheck()
            },
            label: {
                HStack(spacing: 10) {
                    if model.quickCheckRunning {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(
                            systemName: "bolt.horizontal.circle.fill"
                        )
                    }

                    Text(
                        model.quickCheckRunning
                            ? "Checking..."
                            : "Run privacy-safe quick check"
                    )
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
        )
        .buttonStyle(.borderedProminent)
        .tint(SLColor.violet)
        .disabled(model.quickCheckRunning)
        .accessibilityHint(
            "Tests connectivity to the configured diagnostic endpoint"
        )
    }
}
