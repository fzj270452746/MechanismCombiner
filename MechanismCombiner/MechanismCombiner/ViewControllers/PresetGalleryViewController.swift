import UIKit

final class PresetGalleryViewController: UIViewController {

    var onPresetSelected: ((PresetBundle) -> Void)?

    private let backdropView   = UIView()
    private let containerView  = UIView()
    private let titleLabel     = UILabel()
    private let subtitleLabel  = UILabel()
    private let tableView      = UITableView(frame: .zero, style: .plain)
    private let presets        = PresetVault.catalogue

    static func present(on vc: UIViewController, onSelect: @escaping (PresetBundle) -> Void) {
        let gallery = PresetGalleryViewController()
        gallery.onPresetSelected = onSelect
        gallery.modalPresentationStyle = .overFullScreen
        gallery.modalTransitionStyle   = .crossDissolve
        vc.present(gallery, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackdrop()
        setupContainer()
        setupHeader()
        setupTable()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.4) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupBackdrop() {
        backdropView.frame = view.bounds
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        view.addSubview(backdropView)
        backdropView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss(_:))))
    }

    private func setupContainer() {
        let safeBottom = view.safeAreaInsets.bottom
        let h = view.bounds.height * 0.82
        let w = min(view.bounds.width, 480)
        containerView.frame = CGRect(
            x: (view.bounds.width - w) / 2,
            y: view.bounds.height - h - safeBottom,
            width: w, height: h
        )
        containerView.backgroundColor  = PrismTheme.Pigment.abyss
        containerView.layer.cornerRadius = PrismTheme.Radius.xl
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.3).cgColor
        containerView.transform = CGAffineTransform(translationX: 0, y: h)
        containerView.alpha = 0
        view.addSubview(containerView)

        // Drag handle
        let handle = UIView(frame: CGRect(x: (w - 40) / 2, y: 10, width: 40, height: 4))
        handle.backgroundColor = PrismTheme.Pigment.mist.withAlphaComponent(0.4)
        handle.layer.cornerRadius = 2
        containerView.addSubview(handle)
    }

    private func setupHeader() {
        let w = containerView.bounds.width

        // Gradient accent strip at top
        let accentStrip = CAGradientLayer()
        accentStrip.frame = CGRect(x: 0, y: 0, width: w, height: 3)
        accentStrip.colors = PrismTheme.Gradient.nebulaAurora
        accentStrip.startPoint = CGPoint(x: 0, y: 0.5)
        accentStrip.endPoint   = CGPoint(x: 1, y: 0.5)
        containerView.layer.addSublayer(accentStrip)

        titleLabel.text = "Load Preset"
        titleLabel.font = PrismTheme.Glyph.headline(20)
        titleLabel.textColor = PrismTheme.Pigment.ivory
        titleLabel.frame = CGRect(x: 20, y: 28, width: w - 40, height: 28)
        containerView.addSubview(titleLabel)

        subtitleLabel.text = "Choose a built-in configuration to explore"
        subtitleLabel.font = PrismTheme.Glyph.corpus(13)
        subtitleLabel.textColor = PrismTheme.Pigment.mist
        subtitleLabel.frame = CGRect(x: 20, y: 58, width: w - 40, height: 18)
        containerView.addSubview(subtitleLabel)

        let sep = UIView(frame: CGRect(x: 0, y: 84, width: w, height: 1))
        sep.backgroundColor = PrismTheme.Pigment.vault
        containerView.addSubview(sep)
    }

    private func setupTable() {
        let w = containerView.bounds.width
        tableView.frame = CGRect(x: 0, y: 86, width: w, height: containerView.bounds.height - 86)
        tableView.backgroundColor = .clear
        tableView.separatorStyle  = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(PresetCellView.self, forCellReuseIdentifier: PresetCellView.reuseId)
        containerView.addSubview(tableView)
    }

    @objc private func dismiss(_ sender: Any) {
        dismissAnimated()
    }

    private func dismissAnimated() {
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.bounds.height)
            self.backdropView.alpha = 0
        }) { _ in self.dismiss(animated: false) }
    }
}

// MARK: - UITableViewDataSource / Delegate
extension PresetGalleryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { presets.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PresetCellView.reuseId, for: indexPath) as! PresetCellView
        cell.tag = indexPath.row
        cell.configure(with: presets[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 96 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let preset = presets[indexPath.row]
        dismissAnimated()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.onPresetSelected?(preset)
        }
    }
}

// MARK: - Preset Cell
final class PresetCellView: UITableViewCell {
    static let reuseId = "PresetCellView"

    private let cardView     = UIView()
    private let iconBG       = UIView()
    private let iconView     = UIImageView()
    private let nameLabel    = UILabel()
    private let tagLabel     = UILabel()
    private let synopsisLabel = UILabel()
    private let arrowView    = UIImageView()
    private let accentLine   = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupCard()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupCard() {
        cardView.backgroundColor    = PrismTheme.Pigment.cavern
        cardView.layer.cornerRadius = PrismTheme.Radius.lg
        cardView.layer.borderWidth  = 1
        cardView.layer.borderColor  = PrismTheme.Pigment.vault.cgColor
        contentView.addSubview(cardView)

        accentLine.layer.cornerRadius = 2
        cardView.addSubview(accentLine)

        iconBG.layer.cornerRadius = PrismTheme.Radius.md
        cardView.addSubview(iconBG)

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor   = .white
        iconBG.addSubview(iconView)

        nameLabel.font      = PrismTheme.Glyph.subhead(15)
        nameLabel.textColor = PrismTheme.Pigment.ivory
        cardView.addSubview(nameLabel)

        tagLabel.font      = PrismTheme.Glyph.mono(10)
        tagLabel.layer.cornerRadius = 4
        tagLabel.layer.masksToBounds = true
        tagLabel.textAlignment = .center
        cardView.addSubview(tagLabel)

        synopsisLabel.font          = PrismTheme.Glyph.corpus(12)
        synopsisLabel.textColor     = PrismTheme.Pigment.mist
        synopsisLabel.numberOfLines = 2
        cardView.addSubview(synopsisLabel)

        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        arrowView.image       = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        arrowView.tintColor   = PrismTheme.Pigment.mist
        arrowView.contentMode = .scaleAspectFit
        cardView.addSubview(arrowView)
    }

    func configure(with preset: PresetBundle) {
        let w = contentView.bounds.width > 0 ? contentView.bounds.width : 360
        cardView.frame = CGRect(x: 16, y: 8, width: w - 32, height: 80)
        cardView.layer.borderColor = preset.accentColor.withAlphaComponent(0.35).cgColor

        accentLine.frame = CGRect(x: 0, y: 0, width: 4, height: 80)
        accentLine.backgroundColor = preset.accentColor
        accentLine.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        let iconSize: CGFloat = 48
        iconBG.frame = CGRect(x: 16, y: 16, width: iconSize, height: iconSize)
        let grad = CAGradientLayer()
        grad.frame  = iconBG.bounds
        grad.colors = [preset.accentColor.cgColor, preset.accentColor.withAlphaComponent(0.5).cgColor]
        grad.cornerRadius = PrismTheme.Radius.md
        if iconBG.layer.sublayers == nil || iconBG.layer.sublayers!.isEmpty {
            iconBG.layer.insertSublayer(grad, at: 0)
        }
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView.image = UIImage(systemName: preset.sfSymbol, withConfiguration: cfg)
        iconView.frame = CGRect(x: 10, y: 10, width: 28, height: 28)

        let contentX: CGFloat = 80
        let contentW: CGFloat = cardView.bounds.width - contentX - 32

        nameLabel.text  = preset.designation
        nameLabel.frame = CGRect(x: contentX, y: 12, width: contentW, height: 20)

        tagLabel.text = "  \(preset.categoryTag)  "
        tagLabel.textColor    = preset.accentColor
        tagLabel.backgroundColor = preset.accentColor.withAlphaComponent(0.15)
        tagLabel.frame = CGRect(x: contentX, y: 34, width: min(contentW * 0.5, 100), height: 16)

        synopsisLabel.text  = preset.synopsis
        synopsisLabel.frame = CGRect(x: contentX, y: 52, width: contentW, height: 28)

        arrowView.frame = CGRect(x: cardView.bounds.width - 24, y: 33, width: 12, height: 14)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard tag >= 0, tag < PresetVault.catalogue.count else { return }
        configure(with: PresetVault.catalogue[tag])
    }
}
