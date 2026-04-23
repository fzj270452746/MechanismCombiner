import UIKit

final class AnalyticsViewController: UIViewController {

    private let viewModel    = AnalyticsViewModel()
    private let exportEngine = ExportEngine()
    private let headerBG     = UIView()
    private let headerSep    = UIView()
    private let headerLabel  = UILabel()
    private let exportButton = UIButton(type: .system)
    private let scrollView   = UIScrollView()
    private var contentY: CGFloat = 0
    private var didLayoutOnce = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        buildHierarchy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
        if !didLayoutOnce {
            didLayoutOnce = true
            rebuildContent()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didLayoutOnce { rebuildContent() }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupBackground() {
        let grad = CAGradientLayer.prismGradient(colors: PrismTheme.Gradient.obsidianCavern)
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
    }

    private func buildHierarchy() {
        headerBG.backgroundColor = PrismTheme.Pigment.abyss.withAlphaComponent(0.9)
        view.addSubview(headerBG)

        headerSep.backgroundColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.3)
        headerBG.addSubview(headerSep)

        headerLabel.text = "Analytics"
        headerLabel.font = PrismTheme.Glyph.headline(18)
        headerLabel.textColor = PrismTheme.Pigment.ivory
        headerBG.addSubview(headerLabel)

        // Export button
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        exportButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: cfg), for: .normal)
        exportButton.tintColor = PrismTheme.Pigment.aurora
        exportButton.addTarget(self, action: #selector(exportReport), for: .touchUpInside)
        headerBG.addSubview(exportButton)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
    }

    private func layoutViews() {
        let safeTop = view.safeAreaInsets.top
        let w = view.bounds.width
        let headerH: CGFloat = 56
        headerBG.frame    = CGRect(x: 0, y: 0, width: w, height: headerH + safeTop)
        headerSep.frame   = CGRect(x: 0, y: headerH + safeTop - 1, width: w, height: 1)
        headerLabel.frame = CGRect(x: 20, y: safeTop + 14, width: w - 64, height: 28)
        exportButton.frame = CGRect(x: w - 44, y: safeTop + 14, width: 28, height: 28)
        let scrollY = headerH + safeTop
        scrollView.frame  = CGRect(x: 0, y: scrollY, width: w,
                                   height: view.bounds.height - scrollY - 90)
    }

    private func rebuildContent() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        contentY = 12

        guard viewModel.hasResult else { showEmptyState(); return }

        buildSummarySection()
        buildTriggerRateSection()
        buildRTPComparisonSection()
        buildMatrixSection()
        buildSynergyPairsSection()
        buildHistogramSection()
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contentY + 20)
    }

    private func showEmptyState() {
        let icon = UIImageView(image: UIImage(systemName: "chart.bar.xaxis"))
        icon.tintColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.3)
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: scrollView.bounds.midX - 32, y: 60, width: 64, height: 64)
        scrollView.addSubview(icon)

        let label = UILabel(frame: CGRect(x: 20, y: 136, width: scrollView.bounds.width - 40, height: 24))
        label.text = "Run a simulation to see analytics"
        label.font = PrismTheme.Glyph.subhead(16)
        label.textColor = PrismTheme.Pigment.mist
        label.textAlignment = .center
        scrollView.addSubview(label)
    }

    private func buildSummarySection() {
        let stats = viewModel.summaryStats()
        let w     = scrollView.bounds.width - 32
        let card  = addSectionCard(title: "Summary", height: 100, y: contentY, accentColor: PrismTheme.Pigment.solar)
        let statW = (w - 8 * CGFloat(stats.count - 1)) / CGFloat(stats.count)
        for (i, stat) in stats.enumerated() {
            addMiniStat(to: card, label: stat.label, value: stat.value, color: stat.color,
                        frame: CGRect(x: CGFloat(i) * (statW + 8), y: 32, width: statW, height: 64))
        }
        contentY += 116
    }

    private func buildTriggerRateSection() {
        let entries = viewModel.ignitionBarEntries()
        guard !entries.isEmpty else { return }
        let card = addSectionCard(title: "Trigger Rate per Node", height: 160, y: contentY, accentColor: PrismTheme.Pigment.aurora)
        let chart = BarChartRenderer(frame: CGRect(x: 8, y: 38, width: card.frame.width - 16, height: 116))
        chart.entries   = entries
        chart.maxValue  = entries.map { $0.value }.max() ?? 1
        card.addSubview(chart)
        contentY += 176
    }

    private func buildRTPComparisonSection() {
        let entries = viewModel.rtpBarEntries()
        guard !entries.isEmpty else { return }
        let card = addSectionCard(title: "RTP Comparison", height: 160, y: contentY, accentColor: PrismTheme.Pigment.solar)
        let chart = BarChartRenderer(frame: CGRect(x: 8, y: 38, width: card.frame.width - 16, height: 116))
        chart.entries  = entries
        chart.maxValue = entries.map { $0.value }.max() ?? 1
        card.addSubview(chart)
        contentY += 176
    }

    private func buildMatrixSection() {
        let labels = viewModel.matrixLabels()
        guard labels.count > 1 else { return }
        let matrixSide = min(CGFloat(labels.count) * 52 + 54, scrollView.bounds.width - 32)
        let card = addSectionCard(title: "Co-Trigger Matrix", height: matrixSide + 38, y: contentY, accentColor: PrismTheme.Pigment.nebula)
        let matrixChart = MatrixChartRenderer(frame: CGRect(x: 8, y: 38, width: card.frame.width - 16, height: matrixSide))
        matrixChart.labels = labels
        matrixChart.matrix = viewModel.synergyMatrix()
        card.addSubview(matrixChart)
        contentY += matrixSide + 54
    }

    private func buildSynergyPairsSection() {
        let pairs = viewModel.topSynergyPairs()
        guard !pairs.isEmpty else { return }
        let h: CGFloat = CGFloat(pairs.count) * 44 + 44
        let card = addSectionCard(title: "Top Synergy Pairs", height: h, y: contentY, accentColor: PrismTheme.Pigment.verdant)
        for (i, pair) in pairs.enumerated() {
            card.addSubview(addPairRow(to: card, nodeA: pair.nodeA, nodeB: pair.nodeB, rate: pair.rate,
                                      y: 40 + CGFloat(i) * 44))
        }
        contentY += h + 16
    }

    private func buildHistogramSection() {
        let card = addSectionCard(title: "Outcome Distribution", height: 140, y: contentY, accentColor: PrismTheme.Pigment.ember)
        let hist = HistogramRenderer(frame: CGRect(x: 8, y: 38, width: card.frame.width - 16, height: 98))
        hist.samples     = VortexEngine.shared.latestFusionResult.outcomeDistribution
        hist.accentColor = PrismTheme.Pigment.ember
        card.addSubview(hist)
        contentY += 156
    }

    @discardableResult
    private func addSectionCard(title: String, height: CGFloat, y: CGFloat, accentColor: UIColor) -> UIView {
        let w    = scrollView.bounds.width - 32
        let card = UIView(frame: CGRect(x: 16, y: y, width: w, height: height))
        card.backgroundColor = PrismTheme.Pigment.cavern
        card.layer.cornerRadius = PrismTheme.Radius.lg
        card.layer.borderWidth  = 1
        card.layer.borderColor  = accentColor.withAlphaComponent(0.2).cgColor

        let accentLine = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: height))
        accentLine.backgroundColor = accentColor
        accentLine.layer.cornerRadius = 1.5
        accentLine.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        card.addSubview(accentLine)

        let lbl = UILabel(frame: CGRect(x: 14, y: 12, width: w - 28, height: 18))
        lbl.text = title; lbl.font = PrismTheme.Glyph.subhead(13); lbl.textColor = PrismTheme.Pigment.mist
        card.addSubview(lbl)

        scrollView.addSubview(card)
        return card
    }

    private func addMiniStat(to parent: UIView, label: String, value: String, color: UIColor, frame: CGRect) {
        let container = UIView(frame: frame)
        let val = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 28))
        val.text = value; val.font = PrismTheme.Glyph.mono(13); val.textColor = color
        val.textAlignment = .center; val.adjustsFontSizeToFitWidth = true; val.minimumScaleFactor = 0.6
        container.addSubview(val)
        let lbl = UILabel(frame: CGRect(x: 0, y: 28, width: frame.width, height: 14))
        lbl.text = label; lbl.font = PrismTheme.Glyph.corpus(10); lbl.textColor = PrismTheme.Pigment.mist
        lbl.textAlignment = .center
        container.addSubview(lbl)
        parent.addSubview(container)
    }

    private func addPairRow(to parent: UIView, nodeA: String, nodeB: String, rate: Double, y: CGFloat) -> UIView {
        let w   = parent.frame.width - 16
        let row = UIView(frame: CGRect(x: 8, y: y, width: w, height: 36))
        row.backgroundColor = PrismTheme.Pigment.vault
        row.layer.cornerRadius = PrismTheme.Radius.sm

        let pairLabel = UILabel(frame: CGRect(x: 12, y: 8, width: w - 80, height: 20))
        pairLabel.text = "\(nodeA)  ×  \(nodeB)"
        pairLabel.font = PrismTheme.Glyph.subhead(13); pairLabel.textColor = PrismTheme.Pigment.frost
        row.addSubview(pairLabel)

        let rateLabel = UILabel(frame: CGRect(x: w - 68, y: 8, width: 60, height: 20))
        rateLabel.text = String(format: "%.2f%%", rate * 100)
        rateLabel.font = PrismTheme.Glyph.mono(13); rateLabel.textColor = PrismTheme.Pigment.verdant
        rateLabel.textAlignment = .right
        row.addSubview(rateLabel)

        return row
    }

    @objc private func exportReport() {
        guard viewModel.hasResult else {
            BezelDialog.present(on: self,
                                title: "No Data",
                                message: "Run a simulation first before exporting.",
                                variant: .alert,
                                accentColor: PrismTheme.Pigment.ember)
            return
        }

        let pdfData = exportEngine.generateReportPDF(
            result: VortexEngine.shared.latestFusionResult,
            nodes:  VortexEngine.shared.nodeRegistry,
            blueprint: VortexEngine.shared.simulationBlueprint
        )

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MechanismReport_\(Int(Date().timeIntervalSince1970)).pdf")
        try? pdfData.write(to: tmpURL)

        let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.assignToContact, .addToReadingList]

        // iPad popover anchor
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = exportButton
            popover.sourceRect = exportButton.bounds
        }
        present(activityVC, animated: true)
    }
}
