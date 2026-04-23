import Foundation

final class SimulationChamber {

    func ignite(
        nodes: [NexusNode],
        tethers: [TetherLink],
        clashes: [ClashRule],
        blueprint: SimulationBlueprint,
        progress: ((Double) -> Void)? = nil
    ) -> FusionResult {

        guard !nodes.isEmpty else { return .empty }

        let n = blueprint.spinVolume
        let bet = blueprint.baseBet

        var totalYield: Double = 0
        var peakYield: Double = 0
        var ignitionCounts: [String: Int] = [:]
        var pairwiseCounts: [String: Int] = [:]
        var individualYields: [String: Double] = [:]
        var outcomeDistribution: [Double] = []
        let sampleStride = max(1, n / 500)

        nodes.forEach { ignitionCounts[$0.identifier] = 0 }
        nodes.forEach { individualYields[$0.identifier] = 0 }

        for spin in 0..<n {
            if spin % (n / 20) == 0 { progress?(Double(spin) / Double(n)) }

            var firedIds = Set<String>()
            for node in nodes {
                if Double.random(in: 0..<1) < node.ignitionProbability {
                    firedIds.insert(node.identifier)
                }
            }

            firedIds = resolveClashes(firedIds: firedIds, nodes: nodes, clashes: clashes)

            let (boostedFired, yieldBoost) = applyTethers(firedIds: firedIds, nodes: nodes, tethers: tethers)
            firedIds = boostedFired

            var spinYield: Double = 0
            for id in firedIds {
                guard let node = nodes.first(where: { $0.identifier == id }) else { continue }
                spinYield += bet * node.yieldMultiplier
                ignitionCounts[id, default: 0] += 1
                individualYields[id, default: 0] += bet * node.yieldMultiplier
            }
            spinYield *= yieldBoost

            let firedArray = Array(firedIds).sorted()
            for i in 0..<firedArray.count {
                for j in (i+1)..<firedArray.count {
                    let key = "\(firedArray[i])+\(firedArray[j])"
                    pairwiseCounts[key, default: 0] += 1
                }
            }

            totalYield += spinYield
            if spinYield > peakYield { peakYield = spinYield }
            if spin % sampleStride == 0 { outcomeDistribution.append(spinYield) }
        }

        progress?(1.0)

        let totalBet = bet * Double(n)
        let totalRTP = totalBet > 0 ? totalYield / totalBet : 0
        let avgYield = Double(n) > 0 ? totalYield / Double(n) : 0

        var ignitionRates: [String: Double] = [:]
        var individualRTPs: [String: Double] = [:]
        for node in nodes {
            ignitionRates[node.identifier] = Double(ignitionCounts[node.identifier, default: 0]) / Double(n)
            let indivYield = individualYields[node.identifier, default: 0]
            individualRTPs[node.identifier] = totalBet > 0 ? indivYield / totalBet : 0
        }

        var pairwiseRates: [String: Double] = [:]
        for (key, count) in pairwiseCounts {
            pairwiseRates[key] = Double(count) / Double(n)
        }

        let sumIndividualRTP = individualRTPs.values.reduce(0, +)
        let synergyGain = totalRTP - sumIndividualRTP

        return FusionResult(
            totalRTP: totalRTP,
            ignitionRates: ignitionRates,
            pairwiseIgnitionRates: pairwiseRates,
            averageYield: avgYield,
            peakYield: peakYield,
            synergyGain: synergyGain,
            individualRTPs: individualRTPs,
            spinCount: n,
            outcomeDistribution: outcomeDistribution
        )
    }

    private func resolveClashes(firedIds: Set<String>, nodes: [NexusNode], clashes: [ClashRule]) -> Set<String> {
        var result = firedIds
        for rule in clashes {
            guard result.contains(rule.anchorNodeId), result.contains(rule.rivalNodeId) else { continue }
            switch rule.resolution {
            case .precedence:
                result.remove(rule.precedenceRank > 0 ? rule.rivalNodeId : rule.anchorNodeId)
            case .supplant:
                result.remove(rule.rivalNodeId)
            case .nullify:
                result.remove(rule.anchorNodeId)
                result.remove(rule.rivalNodeId)
            }
        }
        return result
    }

    private func applyTethers(firedIds: Set<String>, nodes: [NexusNode], tethers: [TetherLink]) -> (Set<String>, Double) {
        var result = firedIds
        var boostMultiplier: Double = 1.0

        for tether in tethers {
            guard result.contains(tether.originNodeId) else { continue }
            switch tether.variant {
            case .ignition:
                result.insert(tether.destinationNodeId)
            case .amplify:
                if result.contains(tether.destinationNodeId) {
                    boostMultiplier *= tether.amplitudeFactor
                }
            case .repulse:
                result.remove(tether.destinationNodeId)
            }
        }
        return (result, boostMultiplier)
    }
}
