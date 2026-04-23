import UIKit

final class TetherLineView: UIView {

    var tether: TetherLink
    var originPoint: CGPoint
    var destinationPoint: CGPoint

    private let shapeLayer = CAShapeLayer()
    private let arrowLayer = CAShapeLayer()
    private let labelView = UILabel()

    init(tether: TetherLink, from origin: CGPoint, to destination: CGPoint) {
        self.tether = tether
        self.originPoint = origin
        self.destinationPoint = destination
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        setupLayers()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayers() {
        layer.addSublayer(shapeLayer)
        layer.addSublayer(arrowLayer)

        labelView.font = PrismTheme.Glyph.mono(9)
        labelView.textColor = tether.variant.pigment
        labelView.backgroundColor = PrismTheme.Pigment.abyss.withAlphaComponent(0.8)
        labelView.layer.cornerRadius = 4
        labelView.layer.masksToBounds = true
        labelView.textAlignment = .center
        labelView.text = " \(tether.variant.rawValue) "
        addSubview(labelView)
    }

    func updateEndpoints(from origin: CGPoint, to destination: CGPoint) {
        self.originPoint = origin
        self.destinationPoint = destination
        redraw()
    }

    func redraw() {
        let color = tether.variant.pigment.cgColor

        // Bezier curve path
        let path = UIBezierPath()
        path.move(to: originPoint)
        let controlOffset: CGFloat = abs(destinationPoint.x - originPoint.x) * 0.5
        let cp1 = CGPoint(x: originPoint.x + controlOffset, y: originPoint.y)
        let cp2 = CGPoint(x: destinationPoint.x - controlOffset, y: destinationPoint.y)
        path.addCurve(to: destinationPoint, controlPoint1: cp1, controlPoint2: cp2)

        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = tether.variant.dashPattern
        shapeLayer.shadowColor = color
        shapeLayer.shadowOpacity = 0.6
        shapeLayer.shadowRadius = 4
        shapeLayer.shadowOffset = .zero

        // Arrow head at destination
        let angle = atan2(destinationPoint.y - cp2.y, destinationPoint.x - cp2.x)
        let arrowPath = UIBezierPath()
        let arrowLen: CGFloat = 10
        let arrowAngle: CGFloat = .pi / 6
        arrowPath.move(to: destinationPoint)
        arrowPath.addLine(to: CGPoint(
            x: destinationPoint.x - arrowLen * cos(angle - arrowAngle),
            y: destinationPoint.y - arrowLen * sin(angle - arrowAngle)
        ))
        arrowPath.move(to: destinationPoint)
        arrowPath.addLine(to: CGPoint(
            x: destinationPoint.x - arrowLen * cos(angle + arrowAngle),
            y: destinationPoint.y - arrowLen * sin(angle + arrowAngle)
        ))
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.strokeColor = color
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineWidth = 2
        arrowLayer.lineCap = .round

        // Label at midpoint
        let mid = CGPoint(x: (originPoint.x + destinationPoint.x) / 2, y: (originPoint.y + destinationPoint.y) / 2 - 14)
        labelView.sizeToFit()
        labelView.center = mid
    }
}

final class DraftTetherView: UIView {

    private let shapeLayer = CAShapeLayer()
    var startPoint: CGPoint = .zero
    var endPoint: CGPoint = .zero {
        didSet { redraw() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(shapeLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func redraw() {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = PrismTheme.Pigment.aurora.withAlphaComponent(0.7).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [6, 4]
    }

    /// Call this after a connection is completed or cancelled to erase the draft line.
    func clearPath() {
        shapeLayer.path = nil
        startPoint = .zero
        endPoint   = .zero
    }
}
