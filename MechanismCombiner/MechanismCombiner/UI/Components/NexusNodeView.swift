import UIKit

final class NexusNodeView: UIView {

    var node: NexusNode {
        didSet { refreshDisplay() }
    }

    var onTap: ((NexusNode) -> Void)?
    var onDragMoved: ((NexusNodeView, CGPoint) -> Void)?
    var onDragEnded: ((NexusNodeView) -> Void)?
    var onConnectionDrag: ((NexusNodeView, CGPoint) -> Void)?
    var onConnectionEnd: ((NexusNodeView, CGPoint) -> Void)?

    private let gradientLayer = CAGradientLayer()
    private let glowRingLayer = CALayer()
    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    private let probLabel = UILabel()
    private let connectPort = UIView()
    private var isDraggingConnection = false

    static let nodeSize: CGFloat = 80

    init(node: NexusNode) {
        self.node = node
        super.init(frame: CGRect(origin: node.canvasPosition, size: CGSize(width: Self.nodeSize, height: Self.nodeSize + 28)))
        setupAppearance()
        setupGestures()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupAppearance() {
        let nodeBody = UIView(frame: CGRect(x: 0, y: 0, width: Self.nodeSize, height: Self.nodeSize))
        nodeBody.layer.cornerRadius = Self.nodeSize / 2
        nodeBody.layer.masksToBounds = true
        addSubview(nodeBody)

        gradientLayer.frame = nodeBody.bounds
        gradientLayer.cornerRadius = Self.nodeSize / 2
        gradientLayer.colors = node.variant.gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        nodeBody.layer.insertSublayer(gradientLayer, at: 0)

        glowRingLayer.frame = CGRect(x: -4, y: -4, width: Self.nodeSize + 8, height: Self.nodeSize + 8)
        glowRingLayer.cornerRadius = (Self.nodeSize + 8) / 2
        glowRingLayer.borderWidth = 2
        glowRingLayer.borderColor = node.variant.pigment.cgColor
        glowRingLayer.shadowColor = node.variant.pigment.cgColor
        glowRingLayer.shadowOpacity = 0.8
        glowRingLayer.shadowRadius = 8
        glowRingLayer.shadowOffset = .zero
        layer.insertSublayer(glowRingLayer, at: 0)

        iconLabel.text = node.variant.glyphSymbol
        iconLabel.font = PrismTheme.Glyph.headline(26)
        iconLabel.textColor = .white
        iconLabel.textAlignment = .center
        iconLabel.frame = CGRect(x: 0, y: 8, width: Self.nodeSize, height: 36)
        nodeBody.addSubview(iconLabel)

        probLabel.text = String(format: "%.0f%%", node.ignitionProbability * 100)
        probLabel.font = PrismTheme.Glyph.mono(11)
        probLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        probLabel.textAlignment = .center
        probLabel.frame = CGRect(x: 0, y: 46, width: Self.nodeSize, height: 16)
        nodeBody.addSubview(probLabel)

        nameLabel.text = node.designation
        nameLabel.font = PrismTheme.Glyph.corpus(11)
        nameLabel.textColor = PrismTheme.Pigment.frost
        nameLabel.textAlignment = .center
        nameLabel.frame = CGRect(x: -10, y: Self.nodeSize + 4, width: Self.nodeSize + 20, height: 20)
        addSubview(nameLabel)

        // connection port – right edge
        connectPort.frame = CGRect(x: Self.nodeSize - 10, y: Self.nodeSize / 2 - 8, width: 16, height: 16)
        connectPort.backgroundColor = PrismTheme.Pigment.aurora
        connectPort.layer.cornerRadius = 8
        connectPort.layer.borderWidth = 2
        connectPort.layer.borderColor = UIColor.white.cgColor
        addSubview(connectPort)
        bringSubviewToFront(connectPort)
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let portPan = UIPanGestureRecognizer(target: self, action: #selector(handlePortPan(_:)))
        connectPort.addGestureRecognizer(portPan)
    }

    private func refreshDisplay() {
        gradientLayer.colors = node.variant.gradientColors
        glowRingLayer.borderColor = node.variant.pigment.cgColor
        glowRingLayer.shadowColor = node.variant.pigment.cgColor
        iconLabel.text = node.variant.glyphSymbol
        probLabel.text = String(format: "%.0f%%", node.ignitionProbability * 100)
        nameLabel.text = node.designation
    }

    @objc private func handleTap() {
        onTap?(node)
        pulseAnimation()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        if gesture.state == .changed {
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            gesture.setTranslation(.zero, in: superview)
            onDragMoved?(self, center)
        } else if gesture.state == .ended {
            onDragEnded?(self)
        }
    }

    @objc private func handlePortPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: superview)
        switch gesture.state {
        case .began:
            onConnectionDrag?(self, location)
        case .changed:
            onConnectionDrag?(self, location)
        case .ended:
            onConnectionEnd?(self, location)
        case .cancelled, .failed:
            onConnectionEnd?(self, location)
        default:
            break
        }
    }

    private func pulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 8
        pulse.toValue = 20
        pulse.duration = 0.3
        pulse.autoreverses = true
        glowRingLayer.add(pulse, forKey: "pulse")
    }

    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.transform = selected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
        }
        glowRingLayer.borderWidth = selected ? 3 : 2
    }
}
