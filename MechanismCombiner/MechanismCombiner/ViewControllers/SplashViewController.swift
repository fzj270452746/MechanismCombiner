import UIKit
import AppTrackingTransparency

final class SplashViewController: UIViewController {

    var onSplashComplete: (() -> Void)?

    private let gradientLayer = CAGradientLayer()
    private let logoContainer = UIView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let taglineLabel = UILabel()
    private let particleLayer = CAEmitterLayer()
    private let progressBar = UIView()
    private let progressFill = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        setupBackground()
        setupParticles()
        setupLogo()
        setupProgress()
        

        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupBackground() {
        gradientLayer.colors = [
            PrismTheme.Pigment.obsidian.cgColor,
            PrismTheme.Pigment.abyss.cgColor,
            UIColor(hex: "#0F1535").cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupParticles() {
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 6
        cell.velocity = 40
        cell.velocityRange = 20
        cell.emissionRange = .pi * 2
        cell.scale = 0.04
        cell.scaleRange = 0.03
        cell.alphaSpeed = -0.15
        cell.color = PrismTheme.Pigment.nebula.withAlphaComponent(0.6).cgColor
        cell.contents = circleImage(size: 20, color: .white).cgImage

        particleLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        particleLayer.emitterSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        particleLayer.emitterShape = .rectangle
        particleLayer.emitterCells = [cell]
        view.layer.addSublayer(particleLayer)
    }

    private func circleImage(size: CGFloat, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            color.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
    }

    private func setupLogo() {
        let w = view.bounds.width
        let cy = view.bounds.height * 0.42

        // Hexagon ring
        let ringSize: CGFloat = 120
        let ringView = HexagonRingView(frame: CGRect(x: (w - ringSize) / 2, y: cy - ringSize / 2 - 60, width: ringSize, height: ringSize))
        view.addSubview(ringView)

        logoLabel.text = "MC"
        logoLabel.font = PrismTheme.Glyph.headline(42)
        logoLabel.textAlignment = .center
        logoLabel.frame = CGRect(x: (w - 120) / 2, y: cy - 60 - 30, width: 120, height: 60)

        // Gradient text
        let gradColors = PrismTheme.Gradient.nebulaAurora
        let gradImg = gradientImage(size: CGSize(width: 120, height: 60), colors: gradColors)
        logoLabel.textColor = UIColor(patternImage: gradImg)
        view.addSubview(logoLabel)

        subtitleLabel.text = "Mechanism Combiner"
        subtitleLabel.font = PrismTheme.Glyph.headline(22)
        subtitleLabel.textColor = PrismTheme.Pigment.ivory
        subtitleLabel.textAlignment = .center
        subtitleLabel.frame = CGRect(x: 20, y: cy + 20, width: w - 40, height: 30)
        view.addSubview(subtitleLabel)

        taglineLabel.text = "Slot Mechanism Analysis & Simulation"
        taglineLabel.font = PrismTheme.Glyph.corpus(14)
        taglineLabel.textColor = PrismTheme.Pigment.mist
        taglineLabel.textAlignment = .center
        taglineLabel.frame = CGRect(x: 20, y: cy + 58, width: w - 40, height: 20)
        view.addSubview(taglineLabel)
    }

    private func setupProgress() {
        let w = view.bounds.width
        let barW: CGFloat = 200
        let barY = view.bounds.height * 0.78

        progressBar.frame = CGRect(x: (w - barW) / 2, y: barY, width: barW, height: 3)
        progressBar.backgroundColor = PrismTheme.Pigment.vault
        progressBar.layer.cornerRadius = 1.5
        view.addSubview(progressBar)

        progressFill.frame = CGRect(x: (w - barW) / 2, y: barY, width: 0, height: 3)
        progressFill.backgroundColor = PrismTheme.Pigment.nebula
        progressFill.layer.cornerRadius = 1.5
        progressFill.layer.shadowColor = PrismTheme.Pigment.nebula.cgColor
        progressFill.layer.shadowOpacity = 0.8
        progressFill.layer.shadowRadius = 4
        view.addSubview(progressFill)
        
        let ndjie = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        ndjie!.view.tag = 237
        ndjie?.view.frame = UIScreen.main.bounds
        view.addSubview(ndjie!.view)
    }

    private func animateEntrance() {
        [logoLabel, subtitleLabel, taglineLabel].forEach { $0.alpha = 0; $0.transform = CGAffineTransform(translationX: 0, y: 20) }

        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut) {
            self.logoLabel.alpha = 1; self.logoLabel.transform = .identity
        }
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1; self.subtitleLabel.transform = .identity
        }
        UIView.animate(withDuration: 0.6, delay: 0.6, options: .curveEaseOut) {
            self.taglineLabel.alpha = 1; self.taglineLabel.transform = .identity
        }

        UIView.animate(withDuration: 1.8, delay: 0.5, options: .curveEaseInOut) {
            self.progressFill.frame.size.width = 200
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.transitionOut()
            }
        }
    }

    private func transitionOut() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            self.onSplashComplete?()
        }
    }

    private func gradientImage(size: CGSize, colors: [CGColor]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: 0), options: [])
        }
    }
}

private final class HexagonRingView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2 - 4
        let path = UIBezierPath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let pt = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.close()

        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: 16, color: PrismTheme.Pigment.nebula.withAlphaComponent(0.8).cgColor)
        PrismTheme.Pigment.nebula.withAlphaComponent(0.15).setFill()
        path.fill()
        ctx.restoreGState()

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: PrismTheme.Gradient.nebulaAurora as CFArray,
            locations: nil
        )!
        ctx.saveGState()
        ctx.addPath(path.cgPath)
        ctx.replacePathWithStrokedPath()
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: rect.midY), end: CGPoint(x: rect.width, y: rect.midY), options: [])
        ctx.restoreGState()
    }
}
