import UIKit

final class SettingsViewController: UIViewController {

    private let headerBG    = UIView()
    private let headerSep   = UIView()
    private let headerLabel = UILabel()
    private let scrollView  = UIScrollView()
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
            buildContent()
        }
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

        headerLabel.text = "Settings"
        headerLabel.font = PrismTheme.Glyph.headline(18)
        headerLabel.textColor = PrismTheme.Pigment.ivory
        headerBG.addSubview(headerLabel)

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
        headerLabel.frame = CGRect(x: 20, y: safeTop + 14, width: w - 40, height: 28)
        let scrollY = headerH + safeTop
        scrollView.frame  = CGRect(x: 0, y: scrollY, width: w,
                                   height: view.bounds.height - scrollY - 90)
    }

    private func buildContent() {
        contentY = 16
        buildAppInfoSection()
        buildAboutSection()
        buildLegalSection()
        buildDangerSection()
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contentY + 20)
    }

    private func buildAppInfoSection() {
        let card = addCard(title: "About App", y: contentY, height: 140)

        let appIcon = UIView(frame: CGRect(x: 16, y: 36, width: 56, height: 56))
        appIcon.backgroundColor = PrismTheme.Pigment.nebula
        appIcon.layer.cornerRadius = 14
        let grad = CAGradientLayer()
        grad.frame = appIcon.bounds
        grad.colors = PrismTheme.Gradient.nebulaAurora
        grad.cornerRadius = 14
        appIcon.layer.insertSublayer(grad, at: 0)
        let iconLabel = UILabel(frame: appIcon.bounds)
        iconLabel.text = "MC"; iconLabel.font = PrismTheme.Glyph.headline(20)
        iconLabel.textColor = .white; iconLabel.textAlignment = .center
        appIcon.addSubview(iconLabel)
        card.addSubview(appIcon)

        let w = card.frame.width
        [("Mechanism Combiner", 38, PrismTheme.Glyph.headline(16), PrismTheme.Pigment.ivory),
         ("Version 1.0.0",      62, PrismTheme.Glyph.corpus(13),   PrismTheme.Pigment.mist),
         ("Slot Mechanism Analysis Tool", 82, PrismTheme.Glyph.corpus(12), PrismTheme.Pigment.mist.withAlphaComponent(0.6))]
            .forEach { (text, y, font, color) in
                let lbl = UILabel(frame: CGRect(x: 84, y: CGFloat(y), width: w - 100, height: 22))
                lbl.text = text; lbl.font = font; lbl.textColor = color
                card.addSubview(lbl)
            }

        let sep = UIView(frame: CGRect(x: 0, y: 105, width: w, height: 1))
        sep.backgroundColor = PrismTheme.Pigment.vault
        card.addSubview(sep)

        let buildInfo = UILabel(frame: CGRect(x: 16, y: 114, width: w - 32, height: 16))
        buildInfo.text = "Educational & Professional Analysis Tool"
        buildInfo.font = PrismTheme.Glyph.corpus(11)
        buildInfo.textColor = PrismTheme.Pigment.mist.withAlphaComponent(0.5)
        card.addSubview(buildInfo)

        contentY += 156
    }

    private func buildAboutSection() {
        let items: [(String, String, String)] = [
            ("sparkles",          "Mechanism Workshop",     "Design and connect slot mechanisms visually"),
            ("waveform.path.ecg", "Monte Carlo Simulation", "Statistical analysis with up to 100K spins"),
            ("chart.bar.fill",    "Synergy Analytics",      "Discover combined and individual RTP metrics"),
        ]
        let h = CGFloat(items.count) * 60 + 40
        let card = addCard(title: "Features", y: contentY, height: h)
        for (i, item) in items.enumerated() {
            card.addSubview(buildInfoRow(icon: item.0, title: item.1, desc: item.2,
                                        y: 36 + CGFloat(i) * 60, width: card.frame.width))
        }
        contentY += h + 16
    }

    private func buildLegalSection() {
        let card = addCard(title: "Legal", y: contentY, height: 90)
        let disclaimer = UILabel(frame: CGRect(x: 16, y: 36, width: card.frame.width - 32, height: 50))
        disclaimer.text = "This app is an educational tool for game design analysis. It does not involve real money gambling or wagering. All simulations are statistical models for professional research purposes."
        disclaimer.font = PrismTheme.Glyph.corpus(11)
        disclaimer.textColor = PrismTheme.Pigment.mist
        disclaimer.numberOfLines = 0
        card.addSubview(disclaimer)
        let neededH = disclaimer.sizeThatFits(CGSize(width: card.frame.width - 32, height: 200)).height + 52
        card.frame.size.height = neededH
        contentY += neededH + 16
    }

    private func buildDangerSection() {
        let card = addCard(title: "Data", y: contentY, height: 80)
        card.layer.borderColor = PrismTheme.Pigment.crimson.withAlphaComponent(0.3).cgColor

        let btn = UIButton(type: .system)
        btn.setTitle("Clear All Mechanism Data", for: .normal)
        btn.setTitleColor(PrismTheme.Pigment.crimson, for: .normal)
        btn.titleLabel?.font = PrismTheme.Glyph.subhead(15)
        btn.frame = CGRect(x: 16, y: 36, width: card.frame.width - 32, height: 36)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = PrismTheme.Pigment.crimson.withAlphaComponent(0.5).cgColor
        btn.layer.cornerRadius = PrismTheme.Radius.md
        btn.addTarget(self, action: #selector(confirmClearData), for: .touchUpInside)
        card.addSubview(btn)
        contentY += 96
    }

    @objc private func confirmClearData() {
        BezelDialog.present(
            on: self, title: "Clear All Data",
            message: "This will remove all nodes, connections, and simulation results. This cannot be undone.",
            variant: .confirm(onConfirm: { VortexEngine.shared.purgeAll() }),
            accentColor: PrismTheme.Pigment.crimson
        )
    }

    @discardableResult
    private func addCard(title: String, y: CGFloat, height: CGFloat) -> UIView {
        let w    = scrollView.bounds.width - 32
        let card = UIView(frame: CGRect(x: 16, y: y, width: w, height: height))
        card.backgroundColor = PrismTheme.Pigment.cavern
        card.layer.cornerRadius = PrismTheme.Radius.lg
        card.layer.borderWidth  = 1
        card.layer.borderColor  = PrismTheme.Pigment.vault.cgColor

        let lbl = UILabel(frame: CGRect(x: 16, y: 12, width: w - 32, height: 18))
        lbl.text = title; lbl.font = PrismTheme.Glyph.subhead(12); lbl.textColor = PrismTheme.Pigment.mist
        card.addSubview(lbl)
        scrollView.addSubview(card)
        return card
    }

    private func buildInfoRow(icon: String, title: String, desc: String, y: CGFloat, width: CGFloat) -> UIView {
        let row = UIView(frame: CGRect(x: 0, y: y, width: width, height: 56))

        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = PrismTheme.Pigment.nebula
        iv.frame = CGRect(x: 16, y: 14, width: 24, height: 24)
        iv.contentMode = .scaleAspectFit
        row.addSubview(iv)

        let tl = UILabel(frame: CGRect(x: 52, y: 12, width: width - 68, height: 18))
        tl.text = title; tl.font = PrismTheme.Glyph.subhead(14); tl.textColor = PrismTheme.Pigment.frost
        row.addSubview(tl)

        let dl = UILabel(frame: CGRect(x: 52, y: 30, width: width - 68, height: 16))
        dl.text = desc; dl.font = PrismTheme.Glyph.corpus(12); dl.textColor = PrismTheme.Pigment.mist
        row.addSubview(dl)

        let sep = UIView(frame: CGRect(x: 52, y: 55, width: width - 68, height: 1))
        sep.backgroundColor = PrismTheme.Pigment.vault
        row.addSubview(sep)
        return row
    }
}
