import Foundation
import Network

protocol NetworkPathMonitoring: Sendable { func updates() -> AsyncStream<NetworkSnapshot>; func stop() }

final class AppleNetworkPathMonitor: NetworkPathMonitoring, @unchecked Sendable {
    private let monitor = NWPathMonitor(); private let queue = DispatchQueue(label: "com.signallens.pathmonitor")
    func updates() -> AsyncStream<NetworkSnapshot> {
        AsyncStream { continuation in
            monitor.pathUpdateHandler = { path in
                let transport: TransportType = path.usesInterfaceType(.wifi) ? .wifi : path.usesInterfaceType(.cellular) ? .cellular : path.usesInterfaceType(.wiredEthernet) ? .wired : path.status == .satisfied ? .other : .none
                continuation.yield(.init(transport: transport, isConnected: path.status == .satisfied, isExpensive: path.isExpensive, isConstrained: path.isConstrained, supportsIPv4: path.supportsIPv4, supportsIPv6: path.supportsIPv6))
            }
            continuation.onTermination = { [weak self] _ in self?.monitor.cancel() }
            monitor.start(queue: queue)
        }
    }
    func stop() { monitor.cancel() }
}

actor QuickCheckService {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }
    func run(endpoint: URL = URL(string: "https://www.apple.com/library/test/success.html")!) async -> ProbeMeasurement {
        let clock = ContinuousClock(); let start = clock.now
        do {
            let (_, response) = try await session.data(from: endpoint)
            let duration = start.duration(to: clock.now); let ms = Double(duration.components.seconds) * 1000 + Double(duration.components.attoseconds) / 1e15
            let code = (response as? HTTPURLResponse)?.statusCode
            return .init(latencyMS: ms, statusCode: code, succeeded: code.map { 200..<400 ~= $0 } ?? true)
        } catch { return .init(latencyMS: nil, statusCode: nil, succeeded: false, errorCategory: String(describing: error)) }
    }
}
