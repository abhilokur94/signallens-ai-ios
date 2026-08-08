import SwiftUI

struct PrivacyView: View {
    @Environment(AppModel.self) private var model

    @State private var isDeleteConfirmationPresented = false

    var body: some View {
        NavigationStack {
            List {
                collectionBoundarySection
                .listRowBackground(SLColor.panel)

                localDataSection
                .listRowBackground(SLColor.panel)

                platformLimitationsSection
                .listRowBackground(SLColor.panel)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SLColor.ink)
            .navigationTitle("Privacy Center")
            .confirmationDialog(
                "Delete all local telemetry?",
                isPresented: $isDeleteConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(
                    "Delete All Telemetry",
                    role: .destructive
                ) {
                    deleteAllTelemetry()
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) {
                    isDeleteConfirmationPresented = false
                }
            } message: {
                Text(
                    """
                    This removes all locally stored snapshots, probe \
                    measurements, incidents, and timeline events.
                    """
                )
            }
        }
    }

    private var collectionBoundarySection: some View {
        Section {
            privacyRow(
                title: "No packet payloads",
                detail: """
                SignalLens observes network-path state and \
                app-initiated diagnostics only.
                """,
                symbol: "eye.slash"
            )

            privacyRow(
                title: "Local-first",
                detail: """
                Telemetry remains inside this app prototype unless \
                a report is explicitly shared.
                """,
                symbol: "iphone"
            )

            privacyRow(
                title: "Evidence-linked insights",
                detail: """
                Interpretations distinguish observed, derived, and \
                simulated data.
                """,
                symbol: "link"
            )
        } header: {
            Text("Collection Boundary")
        } footer: {
            Text(
                """
                SignalLens does not inspect packet payloads, messages, \
                calls, browsing content, or credentials.
                """
            )
        }
    }

    private var localDataSection: some View {
        Section {
            LabeledContent {
                Text("\(model.store.snapshots.count)")
                    .foregroundStyle(.secondary)
            } label: {
                Label(
                    "Network snapshots",
                    systemImage: "network"
                )
            }

            LabeledContent {
                Text("\(model.store.probes.count)")
                    .foregroundStyle(.secondary)
            } label: {
                Label(
                    "Diagnostic probes",
                    systemImage: "bolt.horizontal.circle"
                )
            }

            LabeledContent {
                Text("\(model.store.incidents.count)")
                    .foregroundStyle(.secondary)
            } label: {
                Label(
                    "Detected incidents",
                    systemImage: "exclamationmark.triangle"
                )
            }

            LabeledContent {
                Text("\(model.store.timeline.count)")
                    .foregroundStyle(.secondary)
            } label: {
                Label(
                    "Timeline events",
                    systemImage: "clock.arrow.circlepath"
                )
            }

            Button(
                role: .destructive,
                action: {
                    isDeleteConfirmationPresented = true
                },
                label: {
                    Label(
                        "Delete all local telemetry",
                        systemImage: "trash"
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            )
        } header: {
            Text("Local Data")
        } footer: {
            Text(
                """
                Deletion immediately clears the current in-memory \
                telemetry store used by this application foundation.
                """
            )
        }
    }

    private var platformLimitationsSection: some View {
        Section {
            HStack(
                alignment: .top,
                spacing: 12
            ) {
                Image(systemName: "lock.shield")
                    .font(.title3)
                    .foregroundStyle(SLColor.cyan)
                    .frame(width: 30)
                    .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: 7
                ) {
                    Text("Application visibility only")
                        .font(.headline)

                    Text(
                        """
                        SignalLens reports only network-path information \
                        and diagnostic results available to the app process.
                        """
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Text(
                        """
                        SignalLens does not claim direct visibility into \
                        carrier RAN, packet-core, IMS, voice, SMS, or \
                        modem-internal systems.
                        """
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Platform Limits")
        }
    }

    private func privacyRow(
        title: String,
        detail: String,
        symbol: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: 12
        ) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(SLColor.cyan)
                .frame(width: 30)
                .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private func deleteAllTelemetry() {
        model.reset()
        isDeleteConfirmationPresented = false
    }
}
