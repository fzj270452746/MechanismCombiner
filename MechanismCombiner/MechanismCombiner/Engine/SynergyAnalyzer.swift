import Foundation

final class SynergyAnalyzer {

    func computeSynergyMatrix(result: FusionResult, nodes: [NexusNode]) -> [[Double]] {
        let count = nodes.count
        var matrix = Array(repeating: Array(repeating: 0.0, count: count), count: count)

        for i in 0..<count {
            for j in (i+1)..<count {
                let keyA = nodes[i].identifier
                let keyB = nodes[j].identifier
                let pairKey = "\(keyA)+\(keyB)"
                let altKey  = "\(keyB)+\(keyA)"
                let rate = result.pairwiseIgnitionRates[pairKey] ?? result.pairwiseIgnitionRates[altKey] ?? 0
                matrix[i][j] = rate
                matrix[j][i] = rate
            }
        }
        return matrix
    }

    func rankSynergyPairs(result: FusionResult, nodes: [NexusNode]) -> [(nodeA: String, nodeB: String, rate: Double)] {
        var pairs: [(String, String, Double)] = []
        for (key, rate) in result.pairwiseIgnitionRates {
            let parts = key.split(separator: "+").map(String.init)
            guard parts.count == 2 else { continue }
            let nameA = nodes.first(where: { $0.identifier == parts[0] })?.designation ?? parts[0]
            let nameB = nodes.first(where: { $0.identifier == parts[1] })?.designation ?? parts[1]
            pairs.append((nameA, nameB, rate))
        }
        return pairs.sorted { $0.2 > $1.2 }
    }

    func detectConflicts(nodes: [NexusNode], tethers: [TetherLink]) -> [String] {
        var warnings: [String] = []
        let repulseTethers = tethers.filter { $0.variant == .repulse }
        for t in repulseTethers {
            let a = nodes.first(where: { $0.identifier == t.originNodeId })?.designation ?? t.originNodeId
            let b = nodes.first(where: { $0.identifier == t.destinationNodeId })?.designation ?? t.destinationNodeId
            warnings.append("⚠ \(a) and \(b) are mutually exclusive")
        }
        return warnings
    }
}
