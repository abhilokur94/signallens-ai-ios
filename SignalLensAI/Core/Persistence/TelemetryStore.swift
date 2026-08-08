import Foundation
import Observation

@MainActor @Observable
final class TelemetryStore {
    private(set) var snapshots: [NetworkSnapshot] = []
    private(set) var probes: [ProbeMeasurement] = []
    private(set) var incidents: [ConnectivityIncident] = []
    private(set) var timeline: [TimelineEvent] = []

    func record(_ snapshot: NetworkSnapshot) {
        snapshots.insert(snapshot, at: 0)
        timeline.insert(.init(timestamp: snapshot.timestamp, title: snapshot.isConnected ? "Path available" : "Path unavailable", detail: "\(snapshot.transport.rawValue) · \(snapshot.provenance.rawValue)", transport: snapshot.transport, provenance: snapshot.provenance), at: 0)
        trim()
    }
    func record(_ probe: ProbeMeasurement) { probes.insert(probe, at: 0); trim() }
    func record(_ incident: ConnectivityIncident) { incidents.insert(incident, at: 0); timeline.insert(.init(timestamp: incident.startedAt, title: incident.title, detail: incident.observation, transport: snapshots.first?.transport ?? .other, provenance: incident.provenance), at: 0); trim() }
    func clear() { snapshots=[]; probes=[]; incidents=[]; timeline=[] }
    private func trim() { snapshots = Array(snapshots.prefix(500)); probes=Array(probes.prefix(200)); incidents=Array(incidents.prefix(100)); timeline=Array(timeline.prefix(700)) }
}
