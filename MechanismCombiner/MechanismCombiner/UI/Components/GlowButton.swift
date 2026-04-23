import UIKit

final class GlowButton: UIButton {

    private let gradientLayer = CAGradientLayer()
    private let glowLayer = CALayer()
    private var gradientColors: [CGColor] = PrismTheme.Gradient.nebulaAurora

    var glowColor: UIColor = PrismTheme.Pigment.nebula {
        didSet { updateGlow() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }

    convenience init(title: String, gradientColors: [CGColor], glowColor: UIColor) {
        self.init(frame: .zero)
        self.gradientColors = gradientColors
        self.glowColor = glowColor
        setTitle(title, for: .normal)
        updateGradient()
        updateGlow()
    }

    private func setupAppearance() {
        layer.cornerRadius = PrismTheme.Radius.md
        layer.masksToBounds = false
        clipsToBounds = false

        gradientLayer.cornerRadius = PrismTheme.Radius.md
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)

        titleLabel?.font = PrismTheme.Glyph.subhead(15)
        setTitleColor(.white, for: .normal)

        updateGlow()
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func updateGradient() {
        gradientLayer.colors = gradientColors
    }

    private func updateGlow() {
        glowLayer.removeFromSuperlayer()
        glowLayer.shadowColor = glowColor.cgColor
        glowLayer.shadowOpacity = 0.7
        glowLayer.shadowRadius = 12
        glowLayer.shadowOffset = .zero
        layer.insertSublayer(glowLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        glowLayer.frame = bounds
        glowLayer.cornerRadius = layer.cornerRadius
        glowLayer.backgroundColor = glowColor.withAlphaComponent(0.3).cgColor
    }

    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.1) { self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
    }

    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.transform = .identity
        }
    }
}
