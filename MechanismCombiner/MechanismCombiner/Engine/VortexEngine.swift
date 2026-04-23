import Foundation

final class VortexEngine {

    static let shared = VortexEngine()
    private init() { loadPersistedState() }

    var nodeRegistry: [NexusNode] = []
    var tetherRegistry: [TetherLink] = []
    var clashRegistry: [ClashRule] = []
    var simulationBlueprint = SimulationBlueprint.defaultBlueprint
    var latestFusionResult: FusionResult = .empty

    var onStateChanged: (() -> Void)?

    // MARK: - Nodes

    func inscribeNode(_ node: NexusNode) {
        nodeRegistry.append(node)
        persistState()
        onStateChanged?()
    }

    func amendNode(_ node: NexusNode) {
        guard let idx = nodeRegistry.firstIndex(where: { $0.identifier == node.identifier }) else { return }
        nodeRegistry[idx] = node
        persistState()
        onStateChanged?()
    }

    func expungeNode(identifier: String) {
        nodeRegistry.removeAll { $0.identifier == identifier }
        tetherRegistry.removeAll { $0.originNodeId == identifier || $0.destinationNodeId == identifier }
        clashRegistry.removeAll { $0.anchorNodeId == identifier || $0.rivalNodeId == identifier }
        persistState()
        onStateChanged?()
    }

    // MARK: - Tethers

    func inscribeTether(_ tether: TetherLink) {
        tetherRegistry.append(tether)
        persistState()
        onStateChanged?()
    }

    func expungeTether(identifier: String) {
        tetherRegistry.removeAll { $0.identifier == identifier }
        persistState()
        onStateChanged?()
    }

    // MARK: - Clashes

    func inscribeClash(_ rule: ClashRule) {
        clashRegistry.append(rule)
        persistState()
        onStateChanged?()
    }

    func expungeClash(identifier: String) {
        clashRegistry.removeAll { $0.identifier == identifier }
        persistState()
        onStateChanged?()
    }

    func purgeAll() {
        nodeRegistry.removeAll()
        tetherRegistry.removeAll()
        clashRegistry.removeAll()
        latestFusionResult = .empty
        persistState()
        onStateChanged?()
    }

    // MARK: - Persistence

    private let persistenceKey = "vortex_engine_state_v1"

    private struct PersistedBundle: Codable {
        var nodes: [NexusNode]
        var tethers: [TetherLink]
        var clashes: [ClashRule]
        var blueprint: SimulationBlueprint
    }

    private func persistState() {
        let bundle = PersistedBundle(
            nodes: nodeRegistry,
            tethers: tetherRegistry,
            clashes: clashRegistry,
            blueprint: simulationBlueprint
        )
        if let data = try? JSONEncoder().encode(bundle) {
            UserDefaults.standard.set(data, forKey: persistenceKey)
        }
    }

    private func loadPersistedState() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let bundle = try? JSONDecoder().decode(PersistedBundle.self, from: data) else { return }
        nodeRegistry = bundle.nodes
        tetherRegistry = bundle.tethers
        clashRegistry = bundle.clashes
        simulationBlueprint = bundle.blueprint
    }
}
