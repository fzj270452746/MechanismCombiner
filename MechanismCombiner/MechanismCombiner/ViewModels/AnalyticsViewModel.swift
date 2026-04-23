import UIKit

final class AnalyticsViewModel {

    private let engine = VortexEngine.shared
    private let analyzer = SynergyAnalyzer()

    var result: FusionResult { engine.latestFusionResult }
    var nodes: [NexusNode] { engine.nodeRegistry }

    var hasResult: Bool { engine.latestFusionResult.spinCount > 0 }

    func ignitionBarEntries() -> [BarChartRenderer.BarEntry] {
        nodes.map { node in
            let rate = result.ignitionRates[node.identifier] ?? 0
            return BarChartRenderer.BarEntry(label: node.designation, value: rate, color: node.variant.pigment)
        }
    }

    func rtpBarEntries() -> [BarChartRenderer.BarEntry] {
        var entries = nodes.map { node -> BarChartRenderer.BarEntry in
            let rtp = result.individualRTPs[node.identifier] ?? 0
            return BarChartRenderer.BarEntry(label: node.designation, value: rtp, color: node.variant.pigment)
        }
        entries.append(BarChartRenderer.BarEntry(
            label: "Combined",
            value: result.totalRTP,
            color: PrismTheme.Pigment.solar
        ))
        return entries
    }

    func synergyMatrix() -> [[Double]] {
        analyzer.computeSynergyMatrix(result: result, nodes: nodes)
    }

    func matrixLabels() -> [String] {
        nodes.map { String($0.designation.prefix(4)) }
    }

    func topSynergyPairs(limit: Int = 5) -> [(nodeA: String, nodeB: String, rate: Double)] {
        Array(analyzer.rankSynergyPairs(result: result, nodes: nodes).prefix(limit))
    }

    func histogramEntries(buckets: Int = 10) -> [BarChartRenderer.BarEntry] {
        let dist = result.outcomeDistribution
        guard !dist.isEmpty else { return [] }
        let minV = dist.min() ?? 0
        let maxV = dist.max() ?? 1
        let range = maxV - minV
        guard range > 0 else { return [] }
        var counts = Array(repeating: 0, count: buckets)
        for val in dist {
            let idx = min(Int((val - minV) / range * Double(buckets)), buckets - 1)
            counts[idx] += 1
        }
        let maxCount = Double(counts.max() ?? 1)
        return counts.enumerated().map { (i, count) in
            let bucketMid = minV + (Double(i) + 0.5) * range / Double(buckets)
            return BarChartRenderer.BarEntry(
                label: String(format: "%.1f", bucketMid),
                value: Double(count) / maxCount,
                color: PrismTheme.Pigment.aurora
            )
        }
    }

    func summaryStats() -> [(label: String, value: String, color: UIColor)] {
        [
            ("Total RTP",    String(format: "%.2f%%", result.totalRTP * 100),    PrismTheme.Pigment.solar),
            ("Avg Yield",    String(format: "%.3f",   result.averageYield),      PrismTheme.Pigment.aurora),
            ("Peak Yield",   String(format: "%.3f",   result.peakYield),         PrismTheme.Pigment.ember),
            ("Synergy Gain", String(format: "%+.2f%%", result.synergyGain * 100), PrismTheme.Pigment.verdant),
            ("Spin Count",   "\(result.spinCount)",                               PrismTheme.Pigment.nebula)
        ]
    }
}
