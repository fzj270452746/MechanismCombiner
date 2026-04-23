import UIKit

final class RadiantTabBar: UIView {

    struct TabItem {
        let sfSymbol: String
        let label: String
    }

    var onTabSelected: ((Int) -> Void)?
    private(set) var selectedIndex: Int = 0
    private var tabButtons: [UIButton] = []
    private let indicatorView = UIView()
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        return UIVisualEffectView(effect: effect)
    }()

    private let items: [TabItem]

    init(items: [TabItem]) {
        self.items = items
        super.init(frame: .zero)
        setupAppearance()
        buildTabs()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupAppearance() {
        layer.cornerRadius = PrismTheme.Radius.xl
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.25).cgColor

        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)

        indicatorView.backgroundColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.2)
        indicatorView.layer.cornerRadius = PrismTheme.Radius.lg
        addSubview(indicatorView)
    }

    private func buildTabs() {
        for (idx, item) in items.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = idx

            let config: UIImage.SymbolConfiguration
            if #available(iOS 15.0, *) {
                config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            } else {
                config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            }
            btn.setImage(UIImage(systemName: item.sfSymbol, withConfiguration: config), for: .normal)
            btn.setTitle(item.label, for: .normal)
            btn.titleLabel?.font = PrismTheme.Glyph.corpus(10)
            btn.tintColor = idx == 0 ? PrismTheme.Pigment.nebula : PrismTheme.Pigment.mist
            btn.setTitleColor(idx == 0 ? PrismTheme.Pigment.nebula : PrismTheme.Pigment.mist, for: .normal)

            // Stack icon + label vertically
            btn.alignImageAndTitleVertically(spacing: 3)
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            addSubview(btn)
            tabButtons.append(btn)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        let tabW = bounds.width / CGFloat(items.count)
        for (idx, btn) in tabButtons.enumerated() {
            btn.frame = CGRect(x: CGFloat(idx) * tabW, y: 0, width: tabW, height: bounds.height)
        }
        updateIndicator(animated: false)
    }

    @objc private func tabTapped(_ sender: UIButton) {
        selectTab(sender.tag, animated: true)
        onTabSelected?(sender.tag)
    }

    func selectTab(_ index: Int, animated: Bool) {
        guard index != selectedIndex else { return }
        let prev = selectedIndex
        selectedIndex = index
        tabButtons[prev].tintColor = PrismTheme.Pigment.mist
        tabButtons[prev].setTitleColor(PrismTheme.Pigment.mist, for: .normal)
        tabButtons[index].tintColor = PrismTheme.Pigment.nebula
        tabButtons[index].setTitleColor(PrismTheme.Pigment.nebula, for: .normal)
        updateIndicator(animated: animated)

        UIView.animate(withDuration: 0.1, animations: {
            self.tabButtons[index].transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.tabButtons[index].transform = .identity
            }
        }
    }

    private func updateIndicator(animated: Bool) {
        let tabW = bounds.width / CGFloat(items.count)
        let pad: CGFloat = 8
        let targetFrame = CGRect(
            x: CGFloat(selectedIndex) * tabW + pad,
            y: pad / 2,
            width: tabW - pad * 2,
            height: bounds.height - pad
        )
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.indicatorView.frame = targetFrame
            }
        } else {
            indicatorView.frame = targetFrame
        }
    }
}

extension UIButton {
    func alignImageAndTitleVertically(spacing: CGFloat = 4) {
        guard let imageSize = imageView?.intrinsicContentSize,
              let titleSize = titleLabel?.intrinsicContentSize else { return }
        let totalH = imageSize.height + spacing + titleSize.height
        imageEdgeInsets = UIEdgeInsets(
            top: -(totalH - imageSize.height) / 2,
            left: 0,
            bottom: (totalH - imageSize.height) / 2,
            right: -titleSize.width
        )
        titleEdgeInsets = UIEdgeInsets(
            top: (totalH - titleSize.height) / 2,
            left: -imageSize.width,
            bottom: -(totalH - titleSize.height) / 2,
            right: 0
        )
    }
}
