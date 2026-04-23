import UIKit

final class ExportEngine {

    func generateReportPDF(
        result: FusionResult,
        nodes: [NexusNode],
        blueprint: SimulationBlueprint
    ) -> Data {
        let pageW: CGFloat = 595   // A4 width  (pt)
        let pageH: CGFloat = 842
        let margin: CGFloat = 40

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageW, height: pageH))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            var cursorY: CGFloat = margin

            cursorY = drawCoverHeader(pageW: pageW, margin: margin, cursorY: cursorY)

            let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
            cursorY = drawMetaRow(
                items: [
                    ("Spin Count",  "\(result.spinCount)"),
                    ("Base Bet",    String(format: "%.2f", blueprint.baseBet)),
                    ("Generated",   dateStr)
                ],
                pageW: pageW, margin: margin, cursorY: cursorY
            )
            cursorY += 16

            cursorY = drawSectionTitle("Summary", pageW: pageW, margin: margin, cursorY: cursorY,
                                       accentColor: UIColor(hex: "#FFD700"))
            let kpis: [(String, String, UIColor)] = [
                ("Total RTP",    String(format: "%.2f%%", result.totalRTP * 100),    UIColor(hex: "#FFD700")),
                ("Avg Yield",    String(format: "%.4f",   result.averageYield),      UIColor(hex: "#00D4FF")),
                ("Peak Yield",   String(format: "%.4f",   result.peakYield),         UIColor(hex: "#FF6B35")),
                ("Synergy Gain", String(format: "%+.2f%%", result.synergyGain * 100), UIColor(hex: "#00E5A0")),
            ]
            cursorY = drawKPIGrid(kpis: kpis, pageW: pageW, margin: margin, cursorY: cursorY)
            cursorY += 16

            cursorY = drawSectionTitle("Node Trigger Rates", pageW: pageW, margin: margin, cursorY: cursorY,
                                       accentColor: UIColor(hex: "#00D4FF"))
            for node in nodes {
                let rate = result.ignitionRates[node.identifier] ?? 0
                let rtp  = result.individualRTPs[node.identifier] ?? 0
                cursorY = drawNodeRow(
                    name: node.designation,
                    variant: node.variant.rawValue,
                    triggerRate: rate,
                    individualRTP: rtp,
                    accentColor: node.variant.pigment,
                    pageW: pageW, margin: margin, cursorY: cursorY
                )
                if cursorY > pageH - 100 {
                    ctx.beginPage(); cursorY = margin
                }
            }
            cursorY += 12

            if cursorY > pageH - 200 { ctx.beginPage(); cursorY = margin }
            cursorY = drawSectionTitle("Trigger Rate Chart", pageW: pageW, margin: margin, cursorY: cursorY,
                                       accentColor: UIColor(hex: "#6C63FF"))
            cursorY = drawBarChart(nodes: nodes, result: result, pageW: pageW, margin: margin, cursorY: cursorY)
            cursorY += 16

            if !result.pairwiseIgnitionRates.isEmpty {
                if cursorY > pageH - 150 { ctx.beginPage(); cursorY = margin }
                cursorY = drawSectionTitle("Co-Trigger Pairs", pageW: pageW, margin: margin, cursorY: cursorY,
                                           accentColor: UIColor(hex: "#00E5A0"))
                let analyzer = SynergyAnalyzer()
                let pairs = analyzer.rankSynergyPairs(result: result, nodes: nodes)
                for pair in pairs.prefix(8) {
                    cursorY = drawPairRow(nodeA: pair.nodeA, nodeB: pair.nodeB, rate: pair.rate,
                                          pageW: pageW, margin: margin, cursorY: cursorY)
                }
                cursorY += 12
            }

            drawFooter(pageW: pageW, pageH: pageH)
        }
    }

    // MARK: - Drawing helpers

    private func drawCoverHeader(pageW: CGFloat, margin: CGFloat, cursorY: CGFloat) -> CGFloat {
        let stripRect = CGRect(x: 0, y: 0, width: pageW, height: 110)
        let stripColor = UIColor(hex: "#0D1225")
        stripColor.setFill()
        UIRectFill(stripRect)

        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.saveGState()
            ctx.setFillColor(UIColor(hex: "#6C63FF").cgColor)
            let accentColors = [UIColor(hex: "#6C63FF").cgColor, UIColor(hex: "#00D4FF").cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: accentColors as CFArray, locations: nil)!
            ctx.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: 108),
                                   end: CGPoint(x: pageW, y: 108), options: [])
            ctx.restoreGState()
        }

        let appName = "Mechanism Combiner"
        let appAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 26, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        (appName as NSString).draw(at: CGPoint(x: margin, y: 26), withAttributes: appAttr)

        let subtitle = "Probability Network Analysis Report"
        let subAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor(hex: "#8892B0")
        ]
        (subtitle as NSString).draw(at: CGPoint(x: margin, y: 62), withAttributes: subAttr)

        return 128
    }

    private func drawMetaRow(items: [(String, String)], pageW: CGFloat, margin: CGFloat, cursorY: CGFloat) -> CGFloat {
        let colW = (pageW - margin * 2) / CGFloat(items.count)
        let keyAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor(hex: "#8892B0")
        ]
        let valAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(hex: "#CCD6F6")
        ]
        for (i, item) in items.enumerated() {
            let x = margin + CGFloat(i) * colW
            (item.0 as NSString).draw(at: CGPoint(x: x, y: cursorY),     withAttributes: keyAttr)
            (item.1 as NSString).draw(at: CGPoint(x: x, y: cursorY + 14), withAttributes: valAttr)
        }
        return cursorY + 36
    }

    private func drawSectionTitle(_ title: String, pageW: CGFloat, margin: CGFloat, cursorY: CGFloat, accentColor: UIColor) -> CGFloat {
        accentColor.setFill()
        UIRectFill(CGRect(x: margin, y: cursorY, width: 4, height: 20))
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor(hex: "#E6F1FF")
        ]
        (title as NSString).draw(at: CGPoint(x: margin + 12, y: cursorY + 2), withAttributes: attr)
        // separator
        UIColor(hex: "#252D50").setFill()
        UIRectFill(CGRect(x: margin, y: cursorY + 26, width: pageW - margin * 2, height: 1))
        return cursorY + 36
    }

    private func drawKPIGrid(kpis: [(String, String, UIColor)], pageW: CGFloat, margin: CGFloat, cursorY: CGFloat) -> CGFloat {
        let colW = (pageW - margin * 2 - CGFloat(kpis.count - 1) * 8) / CGFloat(kpis.count)
        let cardH: CGFloat = 56
        let bgColor = UIColor(hex: "#141830")

        for (i, kpi) in kpis.enumerated() {
            let x = margin + CGFloat(i) * (colW + 8)
            let rect = CGRect(x: x, y: cursorY, width: colW, height: cardH)
            bgColor.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()

            // accent left strip
            kpi.2.setFill()
            UIBezierPath(roundedRect: CGRect(x: x, y: cursorY, width: 3, height: cardH), cornerRadius: 1.5).fill()

            let labelAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor(hex: "#8892B0")
            ]
            let valueAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 16, weight: .bold),
                .foregroundColor: kpi.2
            ]
            (kpi.0 as NSString).draw(at: CGPoint(x: x + 10, y: cursorY + 8),  withAttributes: labelAttr)
            (kpi.1 as NSString).draw(at: CGPoint(x: x + 10, y: cursorY + 26), withAttributes: valueAttr)
        }
        return cursorY + cardH + 8
    }

    private func drawNodeRow(name: String, variant: String, triggerRate: Double, individualRTP: Double,
                              accentColor: UIColor, pageW: CGFloat, margin: CGFloat, cursorY: CGFloat) -> CGFloat {
        let rowH: CGFloat = 36
        UIColor(hex: "#0D1225").setFill()
        UIBezierPath(roundedRect: CGRect(x: margin, y: cursorY, width: pageW - margin * 2, height: rowH), cornerRadius: 6).fill()

        accentColor.setFill()
        UIBezierPath(roundedRect: CGRect(x: margin, y: cursorY, width: 4, height: rowH), cornerRadius: 2).fill()

        let nameAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor(hex: "#CCD6F6")
        ]
        let tagAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: accentColor
        ]
        let valAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(hex: "#E6F1FF")
        ]

        (name    as NSString).draw(at: CGPoint(x: margin + 14, y: cursorY + 4),  withAttributes: nameAttr)
        (variant as NSString).draw(at: CGPoint(x: margin + 14, y: cursorY + 22), withAttributes: tagAttr)

        let rateStr = String(format: "Trigger: %.2f%%",       triggerRate * 100)
        let rtpStr  = String(format: "RTP: %.2f%%",           individualRTP * 100)
        let rw = pageW - margin * 2
        (rateStr as NSString).draw(at: CGPoint(x: margin + rw * 0.52, y: cursorY + 12), withAttributes: valAttr)
        (rtpStr  as NSString).draw(at: CGPoint(x: margin + rw * 0.76, y: cursorY + 12), withAttributes: valAttr)

        return cursorY + rowH + 4
    }

    private func drawBarChart(nodes: [NexusNode], result: FusionResult,
                               pageW: CGFloat, margin: CGFloat, cursorY: CGFloat) -> CGFloat {
        guard !nodes.isEmpty else { return cursorY }
        let chartH: CGFloat  = 100
        let chartW: CGFloat  = pageW - margin * 2
        let barW: CGFloat    = chartW / CGFloat(nodes.count) - 8
        let maxRate          = nodes.compactMap { result.ignitionRates[$0.identifier] }.max() ?? 1

        UIColor(hex: "#0D1225").setFill()
        UIBezierPath(roundedRect: CGRect(x: margin, y: cursorY, width: chartW, height: chartH + 24), cornerRadius: 8).fill()

        for (i, node) in nodes.enumerated() {
            let rate = result.ignitionRates[node.identifier] ?? 0
            let barH = CGFloat(rate / maxRate) * chartH * 0.85
            let x = margin + CGFloat(i) * (barW + 8)
            let y = cursorY + chartH - barH

            let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barW, height: barH), cornerRadius: 3)
            node.variant.pigment.withAlphaComponent(0.85).setFill()
            path.fill()

            let valStr = String(format: "%.1f%%", rate * 100)
            let valAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 8, weight: .regular),
                .foregroundColor: UIColor(hex: "#CCD6F6")
            ]
            let sz = (valStr as NSString).size(withAttributes: valAttr)
            (valStr as NSString).draw(at: CGPoint(x: x + (barW - sz.width) / 2, y: max(y - 12, cursorY + 2)),
                                      withAttributes: valAttr)

            let nameAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8),
                .foregroundColor: UIColor(hex: "#8892B0")
            ]
            let truncated = String(node.designation.prefix(7))
            let ns = (truncated as NSString).size(withAttributes: nameAttr)
            (truncated as NSString).draw(at: CGPoint(x: x + (barW - ns.width) / 2, y: cursorY + chartH + 6),
                                         withAttributes: nameAttr)
        }

        return cursorY + chartH + 28
    }

    private func drawPairRow(nodeA: String, nodeB: String, rate: Double,
                              pageW: CGFloat, margin: CGFloat, cursorY: CGFloat) -> CGFloat {
        let rowH: CGFloat = 30
        UIColor(hex: "#0D1225").setFill()
        UIBezierPath(roundedRect: CGRect(x: margin, y: cursorY, width: pageW - margin * 2, height: rowH), cornerRadius: 6).fill()

        let pairAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor(hex: "#CCD6F6")
        ]
        let rateAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(hex: "#00E5A0")
        ]
        ("\(nodeA)  ×  \(nodeB)" as NSString).draw(at: CGPoint(x: margin + 12, y: cursorY + 8), withAttributes: pairAttr)
        let rStr = String(format: "%.2f%%", rate * 100)
        let rs = (rStr as NSString).size(withAttributes: rateAttr)
        (rStr as NSString).draw(at: CGPoint(x: pageW - margin - rs.width - 12, y: cursorY + 8), withAttributes: rateAttr)

        return cursorY + rowH + 4
    }

    private func drawFooter(pageW: CGFloat, pageH: CGFloat) {
        let text = "Mechanism Combiner · Educational Game Design Analysis Tool · Generated by Monte Carlo Simulation"
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor(hex: "#252D50")
        ]
        let sz = (text as NSString).size(withAttributes: attr)
        (text as NSString).draw(at: CGPoint(x: (pageW - sz.width) / 2, y: pageH - 28), withAttributes: attr)
    }
}
