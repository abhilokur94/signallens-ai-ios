import XCTest
@testable import SignalLensAI

final class IncidentEngineTests:XCTestCase {
 func testOfflineCreatesCriticalIncident(){let incident=IncidentEngine().analyze(previous:nil,current:.init(transport:.none,isConnected:false));XCTAssertEqual(incident?.severity,.critical);XCTAssertEqual(incident?.provenance,.observed)}
 func testTransportChangeCreatesEvidenceLinkedIncident(){let old=NetworkSnapshot(transport:.wifi,isConnected:true);let new=NetworkSnapshot(transport:.cellular,isConnected:true);let incident=IncidentEngine().analyze(previous:old,current:new);XCTAssertEqual(incident?.title,"Network transport changed");XCTAssertEqual(incident?.evidence.count,1)}
 func testConnectedWithoutProbeIsStable(){XCTAssertEqual(IncidentEngine().health(snapshot:.init(transport:.wifi,isConnected:true),latestProbe:nil),.stable)}
}
