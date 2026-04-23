import UIKit

final class WorkshopViewModel {

    private let engine = VortexEngine.shared

    var nodes: [NexusNode] { engine.nodeRegistry }
    var tethers: [TetherLink] { engine.tetherRegistry }
    var clashes: [ClashRule] { engine.clashRegistry }

    var onDataChanged: (() -> Void)?

    init() {
        engine.onStateChanged = { [weak self] in
            self?.onDataChanged?()
        }
    }

    func addNode(variant: NexusVariant, at position: CGPoint) {
        let node = NexusNode(
            designation: "\(variant.rawValue) \(engine.nodeRegistry.count + 1)",
            variant: variant,
            ignitionProbability: defaultProbability(for: variant),
            yieldMultiplier: defaultMultiplier(for: variant),
            canvasPosition: position
        )
        engine.inscribeNode(node)
    }

    func updateNodePosition(_ nodeId: String, position: CGPoint) {
        guard var node = engine.nodeRegistry.first(where: { $0.identifier == nodeId }) else { return }
        node.canvasPosition = position
        engine.amendNode(node)
    }

    func updateNode(_ node: NexusNode) {
        engine.amendNode(node)
    }

    func removeNode(_ nodeId: String) {
        engine.expungeNode(identifier: nodeId)
    }

    func addTether(from originId: String, to destinationId: String, variant: TetherVariant) {
        let exists = engine.tetherRegistry.contains {
            $0.originNodeId == originId && $0.destinationNodeId == destinationId
        }
        guard !exists, originId != destinationId else { return }
        let tether = TetherLink(
            originNodeId: originId,
            destinationNodeId: destinationId,
            variant: variant,
            amplitudeFactor: variant == .amplify ? 1.5 : 1.0
        )
        engine.inscribeTether(tether)
    }

    func removeTether(_ tetherId: String) {
        engine.expungeTether(identifier: tetherId)
    }

    func detectConflictWarnings() -> [String] {
        SynergyAnalyzer().detectConflicts(nodes: nodes, tethers: tethers)
    }

    func clearAll() {
        engine.purgeAll()
    }

    func loadPreset(_ preset: PresetBundle) {
        engine.purgeAll()
        preset.nodes.forEach   { engine.inscribeNode($0) }
        preset.tethers.forEach { engine.inscribeTether($0) }
    }

    private func defaultProbability(for variant: NexusVariant) -> Double {
        switch variant {
        case .wildform:    return 0.20
        case .scatterform: return 0.05
        case .bonusform:   return 0.03
        case .ampliform:   return 0.10
        }
    }

    private func defaultMultiplier(for variant: NexusVariant) -> Double {
        switch variant {
        case .wildform:    return 1.5
        case .scatterform: return 2.0
        case .bonusform:   return 5.0
        case .ampliform:   return 3.0
        }
    }
}
