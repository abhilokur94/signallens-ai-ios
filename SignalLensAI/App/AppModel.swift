import Foundation
import Observation

@MainActor @Observable
final class AppModel {
    let store=TelemetryStore(); private let monitor: NetworkPathMonitoring; private let engine=IncidentEngine(); private let quickCheck=QuickCheckService(); private var monitoringTask:Task<Void,Never>?
    var currentSnapshot:NetworkSnapshot?; var health:ConnectionHealth = .offline; var quickCheckRunning=false; var selectedTab:AppTab = .pulse; var privacyMode=true
    init(monitor:NetworkPathMonitoring=AppleNetworkPathMonitor()){self.monitor=monitor}
    func start(){ guard monitoringTask == nil else{return}; monitoringTask=Task{ [weak self] in guard let self else{return}; for await snapshot in monitor.updates(){ receive(snapshot) } } }
    func stop(){monitor.stop();monitoringTask?.cancel();monitoringTask=nil}
    func receive(_ snapshot:NetworkSnapshot){let previous=currentSnapshot;currentSnapshot=snapshot;store.record(snapshot);if let incident=engine.analyze(previous:previous,current:snapshot){store.record(incident)};health=engine.health(snapshot:snapshot,latestProbe:store.probes.first)}
    func runQuickCheck(){quickCheckRunning=true;Task{let result=await quickCheck.run();store.record(result);health=engine.health(snapshot:currentSnapshot,latestProbe:result);quickCheckRunning=false}}
    func inject(_ snapshots:[NetworkSnapshot]){for snapshot in snapshots{receive(snapshot)}}
    func reset(){store.clear();currentSnapshot=nil;health = .offline}
}
enum AppTab:String,CaseIterable {case pulse="Pulse",timeline="Timeline",incidents="Insights",demo="Demo Lab",privacy="Privacy";var symbol:String{switch self{case .pulse:"waveform.path.ecg";case .timeline:"clock.arrow.circlepath";case .incidents:"shield.lefthalf.filled";case .demo:"sparkles";case .privacy:"lock.shield"}}}
