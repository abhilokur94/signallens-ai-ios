import Foundation

enum DataProvenance: String, Codable, Sendable { case observed, derived, simulated }
enum TransportType: String, Codable, CaseIterable, Sendable { case wifi = "Wi-Fi", cellular = "Cellular", wired = "Wired", other = "Other", none = "Offline" }
enum ConnectionHealth: String, Codable, Sendable { case excellent = "Excellent", stable = "Stable", degraded = "Degraded", unstable = "Unstable", offline = "Offline" }
enum IncidentSeverity: String, Codable, Sendable { case info, warning, critical }

struct NetworkSnapshot: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let transport: TransportType
    let isConnected: Bool
    let isExpensive: Bool
    let isConstrained: Bool
    let supportsIPv4: Bool
    let supportsIPv6: Bool
    let provenance: DataProvenance
    init(id: UUID = UUID(), timestamp: Date = .now, transport: TransportType, isConnected: Bool, isExpensive: Bool = false, isConstrained: Bool = false, supportsIPv4: Bool = false, supportsIPv6: Bool = false, provenance: DataProvenance = .observed) {
        self.id=id; self.timestamp=timestamp; self.transport=transport; self.isConnected=isConnected; self.isExpensive=isExpensive; self.isConstrained=isConstrained; self.supportsIPv4=supportsIPv4; self.supportsIPv6=supportsIPv6; self.provenance=provenance
    }
}

struct ProbeMeasurement: Identifiable, Codable, Equatable, Sendable {
    let id: UUID; let timestamp: Date; let latencyMS: Double?; let statusCode: Int?; let succeeded: Bool; let errorCategory: String?; let provenance: DataProvenance
    init(id: UUID=UUID(), timestamp: Date = .now, latencyMS: Double?, statusCode: Int?, succeeded: Bool, errorCategory: String?=nil, provenance: DataProvenance = .observed) { self.id=id; self.timestamp=timestamp; self.latencyMS=latencyMS; self.statusCode=statusCode; self.succeeded=succeeded; self.errorCategory=errorCategory; self.provenance=provenance }
}

struct IncidentEvidence: Identifiable, Codable, Equatable, Sendable { let id: UUID; let timestamp: Date; let summary: String; let provenance: DataProvenance; init(id: UUID=UUID(), timestamp: Date = .now, summary: String, provenance: DataProvenance) { self.id=id; self.timestamp=timestamp; self.summary=summary; self.provenance=provenance } }
struct ConnectivityIncident: Identifiable, Codable, Equatable, Sendable {
    let id: UUID; let title: String; let severity: IncidentSeverity; let startedAt: Date; var resolvedAt: Date?; let observation: String; let interpretation: String; let confidence: Double; let evidence: [IncidentEvidence]; let provenance: DataProvenance
    init(id: UUID=UUID(), title:String, severity:IncidentSeverity, startedAt:Date = .now, resolvedAt:Date?=nil, observation:String, interpretation:String, confidence:Double, evidence:[IncidentEvidence], provenance:DataProvenance) { self.id=id; self.title=title; self.severity=severity; self.startedAt=startedAt; self.resolvedAt=resolvedAt; self.observation=observation; self.interpretation=interpretation; self.confidence=confidence; self.evidence=evidence; self.provenance=provenance }
}

struct TimelineEvent: Identifiable, Codable, Equatable, Sendable { let id: UUID; let timestamp: Date; let title: String; let detail: String; let transport: TransportType; let provenance: DataProvenance; init(id:UUID=UUID(),timestamp:Date = .now,title:String,detail:String,transport:TransportType,provenance:DataProvenance){self.id=id;self.timestamp=timestamp;self.title=title;self.detail=detail;self.transport=transport;self.provenance=provenance} }
