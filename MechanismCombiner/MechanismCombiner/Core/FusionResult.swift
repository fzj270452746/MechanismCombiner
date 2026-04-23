import Foundation

struct SpinOutcome {
    var ignitedNodeIds: [String]
    var rawYield: Double
    var finalYield: Double
    var synergyTriggered: Bool
}

// MARK: - Fusion Result
struct FusionResult {
    var totalRTP: Double
    var ignitionRates: [String: Double]       // nodeId -> trigger rate
    var pairwiseIgnitionRates: [String: Double] // "A+B" -> co-trigger rate
    var averageYield: Double
    var peakYield: Double
    var synergyGain: Double                   // combined RTP - sum of individual RTPs
    var individualRTPs: [String: Double]      // nodeId -> solo RTP
    var spinCount: Int
    var outcomeDistribution: [Double]         // sampled yields for histogram

    static var empty: FusionResult {
        FusionResult(
            totalRTP: 0, ignitionRates: [:], pairwiseIgnitionRates: [:],
            averageYield: 0, peakYield: 0, synergyGain: 0,
            individualRTPs: [:], spinCount: 0, outcomeDistribution: []
        )
    }
}

// MARK: - Simulation Config
struct SimulationBlueprint: Codable {
    var spinVolume: Int       // 1000 / 10000 / 100000
    var baseBet: Double

    static let presets: [Int] = [1_000, 10_000, 100_000]
    static let defaultBlueprint = SimulationBlueprint(spinVolume: 10_000, baseBet: 1.0)
}
