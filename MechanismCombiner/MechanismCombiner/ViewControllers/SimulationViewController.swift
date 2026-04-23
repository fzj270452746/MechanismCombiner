import UIKit

final class SimulationViewController: UIViewController {

    private let viewModel = SimulationViewModel()

    private let gradLayer          = CAGradientLayer()
    private let headerBG           = UIView()
    private let headerLabel        = UILabel()
    private let configCard         = UIView()
    private let configTitleLabel   = UILabel()
    private let spinLabel          = UILabel()
    private let spinVolumeSegment  = UISegmentedControl(items: ["1K", "10K", "100K"])
    private let betLabel           = UILabel()
    private let configAccentLayer  = CAGradientLayer()
    private let simulateButton     = GlowButton(
        title: "▶  Launch Simulation",
        gradientColors: PrismTheme.Gradient.nebulaAurora,
        glowColor: PrismTheme.Pigment.nebula
    )
    private let progressView      = SimulationProgressView()
    private let resultScrollView  = UIScrollView()
    private var statCards: [MiniStatCard] = []
    private let emptyStateView    = SimulationEmptyStateView()

    private var didLayoutOnce = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        buildHierarchy()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
        if !didLayoutOnce {
            didLayoutOnce = true
            refreshResults()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didLayoutOnce { refreshResults() }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupBackground() {
        gradLayer.colors = PrismTheme.Gradient.obsidianCavern
        view.layer.insertSublayer(gradLayer, at: 0)
    }

    private func buildHierarchy() {
        // Header
        headerBG.backgroundColor = PrismTheme.Pigment.abyss.withAlphaComponent(0.9)
        view.addSubview(headerBG)

        let sep = UIView()
        sep.backgroundColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.3)
        sep.tag = 99
        headerBG.addSubview(sep)

        headerLabel.text = "Simulation"
        headerLabel.font = PrismTheme.Glyph.headline(18)
        headerLabel.textColor = PrismTheme.Pigment.ivory
        headerBG.addSubview(headerLabel)

        // Config card
        configCard.backgroundColor = PrismTheme.Pigment.cavern
        configCard.layer.cornerRadius = PrismTheme.Radius.lg
        configCard.layer.borderWidth  = 1
        configCard.layer.borderColor  = PrismTheme.Pigment.nebula.withAlphaComponent(0.25).cgColor
        view.addSubview(configCard)

        configTitleLabel.text  = "Configuration"
        configTitleLabel.font  = PrismTheme.Glyph.subhead(13)
        configTitleLabel.textColor = PrismTheme.Pigment.mist
        configCard.addSubview(configTitleLabel)

        spinLabel.text      = "Spin Count"
        spinLabel.font      = PrismTheme.Glyph.corpus(13)
        spinLabel.textColor = PrismTheme.Pigment.frost
        configCard.addSubview(spinLabel)

        spinVolumeSegment.selectedSegmentIndex = 1
        spinVolumeSegment.backgroundColor = PrismTheme.Pigment.vault
        spinVolumeSegment.selectedSegmentTintColor = PrismTheme.Pigment.nebula
        let attr:    [NSAttributedString.Key: Any] = [.foregroundColor: PrismTheme.Pigment.mist,  .font: PrismTheme.Glyph.corpus(13)]
        let selAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white,             .font: PrismTheme.Glyph.subhead(13)]
        spinVolumeSegment.setTitleTextAttributes(attr,    for: .normal)
        spinVolumeSegment.setTitleTextAttributes(selAttr, for: .selected)
        spinVolumeSegment.addTarget(self, action: #selector(spinVolumeChanged), for: .valueChanged)
        configCard.addSubview(spinVolumeSegment)

        betLabel.text      = "Base Bet: 1.00"
        betLabel.font      = PrismTheme.Glyph.corpus(13)
        betLabel.textColor = PrismTheme.Pigment.mist
        configCard.addSubview(betLabel)

        configAccentLayer.colors = PrismTheme.Gradient.nebulaAurora
        configAccentLayer.cornerRadius = PrismTheme.Radius.lg
        configAccentLayer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        configCard.layer.addSublayer(configAccentLayer)

        // Simulate button
        simulateButton.addTarget(self, action: #selector(launchSimulation), for: .touchUpInside)
        view.addSubview(simulateButton)

        // Progress
        progressView.isHidden = true
        view.addSubview(progressView)

        // Result scroll view
        resultScrollView.showsVerticalScrollIndicator = false
        resultScrollView.backgroundColor = .clear
        view.addSubview(resultScrollView)

        // Empty state
        resultScrollView.addSubview(emptyStateView)
    }

    private func layoutViews() {
        let safeTop = view.safeAreaInsets.top
        let w = view.bounds.width
        let h = view.bounds.height
        let headerH: CGFloat = 56
        let cardH:   CGFloat = 120
        let gap:     CGFloat = 16

        gradLayer.frame = view.bounds

        // Header
        headerBG.frame = CGRect(x: 0, y: 0, width: w, height: headerH + safeTop)
        headerBG.subviews.first(where: { $0.tag == 99 })?.frame = CGRect(x: 0, y: headerH + safeTop - 1, width: w, height: 1)
        headerLabel.frame = CGRect(x: 20, y: safeTop + 14, width: w - 40, height: 28)

        // Config card
        let cardY = headerH + safeTop + gap
        configCard.frame = CGRect(x: gap, y: cardY, width: w - gap * 2, height: cardH)
        configTitleLabel.frame = CGRect(x: 16, y: 12, width: w - 64, height: 18)
        spinLabel.frame        = CGRect(x: 16, y: 36, width: 80, height: 18)
        spinVolumeSegment.frame = CGRect(x: 100, y: 32, width: w - gap * 2 - 116, height: 28)
        betLabel.frame          = CGRect(x: 16, y: 76, width: w - 64, height: 18)
        configAccentLayer.frame = CGRect(x: 0, y: 0, width: 4, height: cardH)

        // Simulate button
        let btnY = cardY + cardH + gap
        simulateButton.frame = CGRect(x: gap, y: btnY, width: w - gap * 2, height: 52)

        // Progress bar
        progressView.frame = CGRect(x: gap, y: btnY + 52 + 12, width: w - gap * 2, height: 6)

        // Result scroll view
        let resultY = btnY + 52 + 28
        resultScrollView.frame = CGRect(x: 0, y: resultY, width: w, height: h - resultY - 90)
        emptyStateView.frame = resultScrollView.bounds
    }

    private func bindViewModel() {
        viewModel.onProgressUpdate = { [weak self] p in self?.progressView.setProgress(p) }
        viewModel.onSimulationComplete = { [weak self] _ in
            self?.progressView.isHidden = true
            self?.simulateButton.isEnabled = true
            self?.refreshResults()
        }
        viewModel.onSimulationError = { [weak self] msg in
            guard let self = self else { return }
            self.simulateButton.isEnabled = true
            self.progressView.isHidden = true
            BezelDialog.present(on: self, title: "Cannot Simulate", message: msg,
                                variant: .alert, accentColor: PrismTheme.Pigment.ember)
        }
    }

    @objc private func spinVolumeChanged() {
        viewModel.setSpinVolume(SimulationBlueprint.presets[spinVolumeSegment.selectedSegmentIndex])
    }

    @objc private func launchSimulation() {
        simulateButton.isEnabled = false
        progressView.isHidden = false
        progressView.setProgress(0)
        viewModel.launchSimulation()
    }

    private func refreshResults() {
        guard viewModel.latestResult.spinCount > 0 else {
            emptyStateView.isHidden = false; return
        }
        emptyStateView.isHidden = true
        buildResultCards()
    }

    private func buildResultCards() {
        resultScrollView.subviews.forEach { if $0 !== emptyStateView { $0.removeFromSuperview() } }

        let result = viewModel.latestResult
        let nodes  = viewModel.nodes
        let w      = resultScrollView.bounds.width - 32
        var y: CGFloat = 12

        let stats: [(String, String, UIColor)] = [
            ("Total RTP",  String(format: "%.2f%%", result.totalRTP * 100),    PrismTheme.Pigment.solar),
            ("Avg Yield",  String(format: "%.3f",   result.averageYield),      PrismTheme.Pigment.aurora),
            ("Peak Yield", String(format: "%.3f",   result.peakYield),         PrismTheme.Pigment.ember),
            ("Synergy",    String(format: "%+.2f%%", result.synergyGain * 100), PrismTheme.Pigment.verdant)
        ]
        let statW = (resultScrollView.bounds.width - 40) / 2
        for (i, stat) in stats.enumerated() {
            let col = i % 2; let row = i / 2
            let card = MiniStatCard(frame: CGRect(x: 16 + CGFloat(col) * (statW + 8),
                                                  y: y + CGFloat(row) * 72,
                                                  width: statW, height: 64))
            card.configure(label: stat.0, value: stat.1, color: stat.2)
            resultScrollView.addSubview(card)
        }
        y += CGFloat((stats.count + 1) / 2) * 72 + 8

        let triggerCard = buildSectionCard(title: "Trigger Rates", y: y, width: w)
        let barEntries: [BarChartRenderer.BarEntry] = nodes.map { node in
            let rate = result.ignitionRates[node.identifier] ?? 0
            return BarChartRenderer.BarEntry(label: String(node.designation.prefix(6)), value: rate, color: node.variant.pigment)
        }
        if !barEntries.isEmpty {
            let chart = BarChartRenderer(frame: CGRect(x: 16, y: y + 40, width: w, height: 120))
            chart.entries = barEntries
            chart.maxValue = barEntries.map { $0.value }.max() ?? 1
            resultScrollView.addSubview(chart)
        }
        resultScrollView.addSubview(triggerCard)
        y += 170

        if nodes.count > 1 {
            let sg = SynergyGainCard(frame: CGRect(x: 16, y: y, width: w, height: 80))
            sg.configure(individualRTPs: result.individualRTPs,
                         combinedRTP: result.totalRTP,
                         synergyGain: result.synergyGain,
                         nodes: nodes)
            resultScrollView.addSubview(sg)
            y += 92
        }

        resultScrollView.contentSize = CGSize(width: resultScrollView.bounds.width, height: y + 20)
    }

    private func buildSectionCard(title: String, y: CGFloat, width: CGFloat) -> UIView {
        let card = UIView(frame: CGRect(x: 16, y: y, width: width, height: 160))
        card.backgroundColor = PrismTheme.Pigment.cavern
        card.layer.cornerRadius = PrismTheme.Radius.lg
        card.layer.borderWidth = 1
        card.layer.borderColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.2).cgColor
        let lbl = UILabel(frame: CGRect(x: 16, y: 12, width: width - 32, height: 18))
        lbl.text = title; lbl.font = PrismTheme.Glyph.subhead(13); lbl.textColor = PrismTheme.Pigment.mist
        card.addSubview(lbl)
        return card
    }
}

// MARK: - Simulation Progress View
final class SimulationProgressView: UIView {
    private let fillView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = PrismTheme.Pigment.vault
        layer.cornerRadius = 3
        fillView.backgroundColor = PrismTheme.Pigment.nebula
        fillView.layer.cornerRadius = 3
        fillView.layer.shadowColor   = PrismTheme.Pigment.nebula.cgColor
        fillView.layer.shadowOpacity = 0.8
        fillView.layer.shadowRadius  = 4
        addSubview(fillView)
    }
    required init?(coder: NSCoder) { fatalError() }

    func setProgress(_ p: Double) {
        UIView.animate(withDuration: 0.1) {
            self.fillView.frame = CGRect(x: 0, y: 0,
                                        width: self.bounds.width * CGFloat(p),
                                        height: self.bounds.height)
        }
    }
}

// MARK: - Mini Stat Card
final class MiniStatCard: UIView {
    private let valueLabel = UILabel()
    private let labelText  = UILabel()
    private let accentLine = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = PrismTheme.Pigment.cavern
        layer.cornerRadius = PrismTheme.Radius.md
        layer.borderWidth = 1
        layer.borderColor = PrismTheme.Pigment.vault.cgColor

        accentLine.frame = CGRect(x: 0, y: 0, width: 3, height: frame.height)
        accentLine.layer.cornerRadius = 1.5
        accentLine.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        addSubview(accentLine)

        valueLabel.font = PrismTheme.Glyph.headline(20)
        valueLabel.textColor = PrismTheme.Pigment.ivory
        valueLabel.frame = CGRect(x: 14, y: 10, width: frame.width - 18, height: 28)
        addSubview(valueLabel)

        labelText.font = PrismTheme.Glyph.corpus(12)
        labelText.textColor = PrismTheme.Pigment.mist
        labelText.frame = CGRect(x: 14, y: 38, width: frame.width - 18, height: 16)
        addSubview(labelText)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(label: String, value: String, color: UIColor) {
        valueLabel.text = value; valueLabel.textColor = color
        labelText.text  = label
        accentLine.backgroundColor = color
        layer.borderColor = color.withAlphaComponent(0.25).cgColor
    }
}

// MARK: - Synergy Gain Card
final class SynergyGainCard: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let descLabel  = UILabel()
    private let gradLayer  = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = PrismTheme.Pigment.cavern
        layer.cornerRadius = PrismTheme.Radius.md
        layer.borderWidth  = 1

        gradLayer.frame = CGRect(x: 0, y: 0, width: 4, height: frame.height)
        gradLayer.colors = PrismTheme.Gradient.verdantAurora
        gradLayer.cornerRadius = PrismTheme.Radius.md
        gradLayer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.addSublayer(gradLayer)

        titleLabel.text = "Synergy Gain"
        titleLabel.font = PrismTheme.Glyph.subhead(13)
        titleLabel.textColor = PrismTheme.Pigment.mist
        titleLabel.frame = CGRect(x: 16, y: 12, width: frame.width - 32, height: 18)
        addSubview(titleLabel)

        valueLabel.font = PrismTheme.Glyph.headline(24)
        valueLabel.textColor = PrismTheme.Pigment.verdant
        valueLabel.frame = CGRect(x: 16, y: 30, width: 120, height: 32)
        addSubview(valueLabel)

        descLabel.font = PrismTheme.Glyph.corpus(11)
        descLabel.textColor = PrismTheme.Pigment.mist
        descLabel.numberOfLines = 2
        descLabel.frame = CGRect(x: 140, y: 24, width: frame.width - 156, height: 40)
        addSubview(descLabel)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(individualRTPs: [String: Double], combinedRTP: Double, synergyGain: Double, nodes: [NexusNode]) {
        valueLabel.text = String(format: "%+.2f%%", synergyGain * 100)
        valueLabel.textColor = synergyGain >= 0 ? PrismTheme.Pigment.verdant : PrismTheme.Pigment.crimson
        layer.borderColor = (synergyGain >= 0 ? PrismTheme.Pigment.verdant : PrismTheme.Pigment.crimson).withAlphaComponent(0.3).cgColor
        let sumIndiv = individualRTPs.values.reduce(0, +)
        descLabel.text = "Combined: \(String(format: "%.2f%%", combinedRTP * 100))\nSum of singles: \(String(format: "%.2f%%", sumIndiv * 100))"
    }
}

// MARK: - Empty State View
final class SimulationEmptyStateView: UIView {

    private let iconView  = UIImageView()
    private let titleLbl  = UILabel()
    private let subLbl    = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView.image        = UIImage(systemName: "waveform.path.ecg")
        iconView.tintColor    = PrismTheme.Pigment.nebula.withAlphaComponent(0.4)
        iconView.contentMode  = .scaleAspectFit
        addSubview(iconView)

        titleLbl.text          = "No simulation results yet"
        titleLbl.font          = PrismTheme.Glyph.subhead(16)
        titleLbl.textColor     = PrismTheme.Pigment.mist
        titleLbl.textAlignment = .center
        addSubview(titleLbl)

        subLbl.text          = "Add nodes in Workshop, then tap\nLaunch Simulation"
        subLbl.font          = PrismTheme.Glyph.corpus(13)
        subLbl.textColor     = PrismTheme.Pigment.mist.withAlphaComponent(0.6)
        subLbl.textAlignment = .center
        subLbl.numberOfLines = 2
        addSubview(subLbl)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        iconView.frame = CGRect(x: (w - 60) / 2, y: 40, width: 60, height: 60)
        titleLbl.frame = CGRect(x: 20, y: 112, width: w - 40, height: 24)
        subLbl.frame   = CGRect(x: 20, y: 140, width: w - 40, height: 40)
    }
}
