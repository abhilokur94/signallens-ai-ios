import SwiftUI

struct IncidentsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            List {
                if model.store.incidents.isEmpty {
                    emptyState
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(model.store.incidents) { incident in
                        NavigationLink {
                            IncidentDetailView(incident: incident)
                        } label: {
                            IncidentRowView(incident: incident)
                        }
                        .listRowBackground(SLColor.panel)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SLColor.ink)
            .navigationTitle("Insights")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                "No incidents detected",
                systemImage: "checkmark.shield"
            )
        } description: {
            Text(
                """
                Observed and simulated incidents will appear here \
                with evidence-linked explanations.
                """
            )
        } actions: {
            Button {
                model.selectedTab = .demo
            } label: {
                Label(
                    "Open Demo Lab",
                    systemImage: "sparkles"
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(SLColor.violet)
        }
    }
}

private struct IncidentRowView: View {
    let incident: ConnectivityIncident

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            HStack(
                alignment: .firstTextBaseline,
                spacing: 10
            ) {
                severityIndicator

                Text(incident.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                ProvenanceBadge(
                    value: incident.provenance
                )
            }

            Text(incident.observation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack(spacing: 14) {
                Label(
                    "Confidence \(confidencePercentage)%",
                    systemImage: "checkmark.seal"
                )

                Label(
                    "\(incident.evidence.count) evidence",
                    systemImage: "link"
                )
            }
            .font(.caption)
            .foregroundStyle(SLColor.cyan)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private var confidencePercentage: Int {
        let boundedConfidence = min(
            max(incident.confidence, 0),
            1
        )

        return Int(
            (boundedConfidence * 100).rounded()
        )
    }

    private var severityIndicator: some View {
        Circle()
            .fill(severityColor)
            .frame(width: 9, height: 9)
            .accessibilityHidden(true)
    }

    private var severityColor: Color {
        switch incident.severity {
        case .info:
            return SLColor.cyan
        case .warning:
            return .orange
        case .critical:
            return .red
        }
    }
}

struct IncidentDetailView: View {
    let incident: ConnectivityIncident

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 18
            ) {
                incidentHeader

                detailSection(
                    title: "Observation",
                    symbol: "eye",
                    text: incident.observation
                )

                detailSection(
                    title: "Interpretation",
                    symbol: "lightbulb",
                    text: incident.interpretation
                )

                confidenceSection

                evidenceSection

                limitationsSection
            }
            .padding()
        }
        .background(
            SLColor.ink
                .ignoresSafeArea()
        )
        .navigationTitle(incident.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var incidentHeader: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: severitySymbol)
                    .font(.title2)
                    .foregroundStyle(severityColor)
                    .frame(width: 42, height: 42)
                    .background(
                        severityColor.opacity(0.14),
                        in: RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                    )

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(severityLabel)
                        .font(.caption.bold())
                        .foregroundStyle(severityColor)

                    Text(
                        incident.startedAt.formatted(
                            date: .abbreviated,
                            time: .standard
                        )
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                ProvenanceBadge(
                    value: incident.provenance
                )
            }
        }
    }

    private var confidenceSection: some View {
        GlassCard {
            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                Label(
                    "Confidence",
                    systemImage: "checkmark.seal"
                )
                .font(.caption.bold())
                .foregroundStyle(SLColor.cyan)

                HStack {
                    Text("\(confidencePercentage)%")
                        .font(
                            .system(
                                size: 32,
                                weight: .bold,
                                design: .rounded
                            )
                        )

                    Spacer()

                    Text(confidenceLabel)
                        .font(.subheadline.bold())
                        .foregroundStyle(
                            confidenceColor
                        )
                }

                ProgressView(
                    value: boundedConfidence
                )
                .tint(confidenceColor)

                Text(
                    """
                    Confidence describes how strongly the captured \
                    application-visible evidence supports this interpretation.
                    """
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var evidenceSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("Evidence")
                .font(.title2.bold())

            if incident.evidence.isEmpty {
                GlassCard {
                    Label(
                        "No supporting evidence was recorded.",
                        systemImage: "exclamationmark.triangle"
                    )
                    .foregroundStyle(.secondary)
                }
            } else {
                ForEach(incident.evidence) { evidence in
                    EvidenceCard(evidence: evidence)
                }
            }
        }
    }

    private var limitationsSection: some View {
        GlassCard {
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                Label(
                    "Visibility boundary",
                    systemImage: "lock.shield"
                )
                .font(.caption.bold())
                .foregroundStyle(SLColor.cyan)

                Text(
                    """
                    This interpretation uses only network-path state and \
                    diagnostics visible to the SignalLens process. It is not \
                    a diagnosis of carrier RAN, packet-core, IMS, voice, or \
                    SMS infrastructure.
                    """
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func detailSection(
        title: String,
        symbol: String,
        text: String
    ) -> some View {
        GlassCard {
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                Label(
                    title,
                    systemImage: symbol
                )
                .font(.caption.bold())
                .foregroundStyle(SLColor.cyan)

                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    private var boundedConfidence: Double {
        min(
            max(incident.confidence, 0),
            1
        )
    }

    private var confidencePercentage: Int {
        Int(
            (boundedConfidence * 100).rounded()
        )
    }

    private var confidenceLabel: String {
        switch boundedConfidence {
        case 0.85...:
            return "High"
        case 0.60..<0.85:
            return "Moderate"
        default:
            return "Limited"
        }
    }

    private var confidenceColor: Color {
        switch boundedConfidence {
        case 0.85...:
            return SLColor.cyan
        case 0.60..<0.85:
            return .orange
        default:
            return .red
        }
    }

    private var severityLabel: String {
        switch incident.severity {
        case .info:
            return "INFORMATION"
        case .warning:
            return "WARNING"
        case .critical:
            return "CRITICAL"
        }
    }

    private var severitySymbol: String {
        switch incident.severity {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "exclamationmark.octagon.fill"
        }
    }

    private var severityColor: Color {
        switch incident.severity {
        case .info:
            return SLColor.cyan
        case .warning:
            return .orange
        case .critical:
            return .red
        }
    }
}

private struct EvidenceCard: View {
    let evidence: IncidentEvidence

    var body: some View {
        GlassCard {
            HStack(
                alignment: .top,
                spacing: 12
            ) {
                Image(systemName: "link")
                    .foregroundStyle(SLColor.cyan)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    Text(evidence.summary)
                        .font(.body)

                    Text(
                        evidence.timestamp.formatted(
                            date: .omitted,
                            time: .standard
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                ProvenanceBadge(
                    value: evidence.provenance
                )
            }
        }
        .accessibilityElement(children: .combine)
    }
}
