import SwiftUI

struct TimelineView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            List {
                if model.store.timeline.isEmpty {
                    emptyState
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(model.store.timeline) { event in
                        TimelineEventRow(event: event)
                            .listRowBackground(SLColor.panel)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SLColor.ink)
            .navigationTitle("Connectivity Timeline")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                "No events yet",
                systemImage: "clock"
            )
        } description: {
            Text(
                """
                Path changes, detected incidents, and Demo Lab events \
                will appear here.
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

private struct TimelineEventRow: View {
    let event: TimelineEvent

    var body: some View {
        HStack(
            alignment: .top,
            spacing: 12
        ) {
            eventMarker

            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 8
                ) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 8)

                    Text(
                        event.timestamp.formatted(
                            date: .omitted,
                            time: .standard
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }

                Text(event.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                HStack(spacing: 10) {
                    Label(
                        event.transport.rawValue,
                        systemImage: transportSymbol
                    )
                    .font(.caption)
                    .foregroundStyle(transportColor)

                    Spacer()

                    ProvenanceBadge(
                        value: event.provenance
                    )
                }
            }
        }
        .padding(.vertical, 7)
        .accessibilityElement(children: .combine)
    }

    private var eventMarker: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(markerColor.opacity(0.18))
                    .frame(width: 38, height: 38)

                Image(systemName: transportSymbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(markerColor)
            }

            Rectangle()
                .fill(markerColor.opacity(0.28))
                .frame(width: 2, height: 30)
        }
        .accessibilityHidden(true)
    }

    private var transportSymbol: String {
        switch event.transport {
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

    private var transportColor: Color {
        switch event.transport {
        case .wifi:
            return SLColor.cyan

        case .cellular:
            return SLColor.violet

        case .wired:
            return .green

        case .other:
            return .secondary

        case .none:
            return .red
        }
    }

    private var markerColor: Color {
        if event.provenance == .simulated {
            return .orange
        }

        return transportColor
    }
}

// MARK: - Reusable Network Pulse Shape

extension TimelineView {
    struct PulseShape: Shape {
        let samples: Int

        func path(
            in rect: CGRect
        ) -> Path {
            var path = Path()

            guard rect.width > 0,
                  rect.height > 0 else {
                return path
            }

            let safeSampleCount = max(samples, 1)
            let stepCount = max(
                safeSampleCount * 4,
                12
            )

            path.move(
                to: CGPoint(
                    x: rect.minX,
                    y: rect.midY
                )
            )

            for index in 1...stepCount {
                let progress =
                    CGFloat(index) /
                    CGFloat(stepCount)

                let x =
                    rect.minX +
                    rect.width * progress

                let isMajorPulse =
                    index.isMultiple(of: 4)

                let amplitude =
                    isMajorPulse
                    ? rect.height * 0.35
                    : rect.height * 0.11

                let phase =
                    CGFloat(index) * 1.7

                let y =
                    rect.midY +
                    sin(phase) * amplitude

                path.addLine(
                    to: CGPoint(
                        x: x,
                        y: y
                    )
                )
            }

            return path
        }
    }
}
