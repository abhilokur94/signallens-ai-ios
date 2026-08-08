import Foundation

struct IncidentEngine: Sendable {
    func analyze(previous: NetworkSnapshot?, current: NetworkSnapshot) -> ConnectivityIncident? {
        if !current.isConnected {
            return .init(title:"Connection unavailable", severity:.critical, observation:"The system network path is not currently satisfied.", interpretation:"Network-dependent operations may remain pending until a usable path returns.", confidence:0.98, evidence:[.init(timestamp:current.timestamp,summary:"NWPath reported an unsatisfied path.",provenance:current.provenance)],provenance:current.provenance)
        }
        if let previous, previous.transport != current.transport, previous.isConnected {
            return .init(title:"Network transport changed",severity:.warning,observation:"The active path changed from \(previous.transport.rawValue) to \(current.transport.rawValue).",interpretation:"In-flight work may experience additional latency or retries during the transition.",confidence:0.92,evidence:[.init(timestamp:current.timestamp,summary:"Observed transport transition.",provenance:current.provenance)],provenance:current.provenance)
        }
        if current.isConstrained { return .init(title:"Constrained network path",severity:.warning,observation:"iOS marked the current path as constrained.",interpretation:"The app should minimize discretionary transfer and preserve essential operations.",confidence:0.95,evidence:[.init(timestamp:current.timestamp,summary:"NWPath isConstrained is true.",provenance:current.provenance)],provenance:current.provenance) }
        return nil
    }
    func health(snapshot: NetworkSnapshot?, latestProbe: ProbeMeasurement?) -> ConnectionHealth {
        guard let snapshot, snapshot.isConnected else { return .offline }
        if let probe = latestProbe, !probe.succeeded { return .unstable }
        if snapshot.isConstrained { return .degraded }
        if let ms = latestProbe?.latencyMS, ms > 400 { return .degraded }
        return latestProbe == nil ? .stable : .excellent
    }
}
