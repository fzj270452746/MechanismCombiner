import Foundation

final class SimulationViewModel {

    private let engine = VortexEngine.shared
    private let chamber = SimulationChamber()

    var blueprint: SimulationBlueprint {
        get { engine.simulationBlueprint }
        set { engine.simulationBlueprint = newValue }
    }

    var latestResult: FusionResult { engine.latestFusionResult }
    var nodes: [NexusNode] { engine.nodeRegistry }

    var onProgressUpdate: ((Double) -> Void)?
    var onSimulationComplete: ((FusionResult) -> Void)?
    var onSimulationError: ((String) -> Void)?

    private var simulationTask: DispatchWorkItem?

    func launchSimulation() {
        guard !engine.nodeRegistry.isEmpty else {
            onSimulationError?("Add at least one mechanism node before simulating.")
            return
        }

        let nodes = engine.nodeRegistry
        let tethers = engine.tetherRegistry
        let clashes = engine.clashRegistry
        let blueprint = engine.simulationBlueprint

        simulationTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let result = self.chamber.ignite(
                nodes: nodes,
                tethers: tethers,
                clashes: clashes,
                blueprint: blueprint,
                progress: { p in
                    DispatchQueue.main.async { self.onProgressUpdate?(p) }
                }
            )
            DispatchQueue.main.async {
                self.engine.latestFusionResult = result
                self.onSimulationComplete?(result)
            }
        }
        simulationTask = task
        DispatchQueue.global(qos: .userInitiated).async(execute: task)
    }

    func cancelSimulation() {
        simulationTask?.cancel()
        simulationTask = nil
    }

    func setSpinVolume(_ volume: Int) {
        engine.simulationBlueprint.spinVolume = volume
    }

    func nodeName(for id: String) -> String {
        engine.nodeRegistry.first(where: { $0.identifier == id })?.designation ?? id
    }
}
