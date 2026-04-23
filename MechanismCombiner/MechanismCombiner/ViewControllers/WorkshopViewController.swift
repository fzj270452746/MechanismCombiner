import UIKit

final class WorkshopViewController: UIViewController {

    private let viewModel = WorkshopViewModel()
    private let scrollView = UIScrollView()
    private let canvasView = UIView()
    private var nodeViews: [String: NexusNodeView] = [:]
    private var tetherViews: [String: TetherLineView] = [:]
    private var draftTetherView: DraftTetherView?
    private var draftOriginNodeView: NexusNodeView?

    // Header views – stored so we can re-layout in viewDidLayoutSubviews
    private let headerView     = UIView()
    private let headerSep      = UIView()
    private let titleLabel     = UILabel()
    private let nodeCountBadge = UILabel()
    private let addNodeButton  = GlowButton(
        title: "+ Node",
        gradientColors: PrismTheme.Gradient.nebulaAurora,
        glowColor: PrismTheme.Pigment.nebula
    )
    private let templatesButton = UIButton(type: .system)
    private let clearButton     = UIButton(type: .system)
    private let hintLabel       = UILabel()

    let canvasSize = CGSize(width: 1200, height: 900)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        buildHeaderHierarchy()
        buildCanvas()
        buildHintLabel()
        bindViewModel()
        
        NetworkMonitor.shared.start { connected in
            if connected {
                _ = AzurePrinceGameView()
                NetworkMonitor.shared.stop()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
        // initial canvas load happens once layout is known
        if nodeViews.isEmpty { reloadCanvas() }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupBackground() {
        let grad = CAGradientLayer.prismGradient(colors: PrismTheme.Gradient.obsidianCavern)
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
    }

    private func buildHeaderHierarchy() {
        headerView.backgroundColor = PrismTheme.Pigment.abyss.withAlphaComponent(0.9)
        view.addSubview(headerView)

        headerSep.backgroundColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.3)
        headerView.addSubview(headerSep)

        titleLabel.text = "Workshop"
        titleLabel.font = PrismTheme.Glyph.headline(18)
        titleLabel.textColor = PrismTheme.Pigment.ivory
        headerView.addSubview(titleLabel)

        nodeCountBadge.font = PrismTheme.Glyph.mono(12)
        nodeCountBadge.textColor = PrismTheme.Pigment.aurora
        nodeCountBadge.textAlignment = .center
        view.addSubview(nodeCountBadge)

        addNodeButton.addTarget(self, action: #selector(showAddNodePicker), for: .touchUpInside)
        headerView.addSubview(addNodeButton)

        templatesButton.setTitle("Templates", for: .normal)
        templatesButton.setTitleColor(PrismTheme.Pigment.aurora, for: .normal)
        templatesButton.titleLabel?.font = PrismTheme.Glyph.corpus(13)
        templatesButton.addTarget(self, action: #selector(showPresetGallery), for: .touchUpInside)
        headerView.addSubview(templatesButton)

        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(PrismTheme.Pigment.crimson, for: .normal)
        clearButton.titleLabel?.font = PrismTheme.Glyph.corpus(14)
        clearButton.addTarget(self, action: #selector(confirmClearAll), for: .touchUpInside)
        headerView.addSubview(clearButton)
    }

    private func buildCanvas() {
        scrollView.backgroundColor = .clear
        scrollView.contentSize = canvasSize
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2.0
        scrollView.delegate = self
        view.addSubview(scrollView)

        canvasView.frame = CGRect(origin: .zero, size: canvasSize)
        canvasView.backgroundColor = UIColor(hex: "#0C1020")
        let gridLayer = GridPatternLayer()
        gridLayer.frame = canvasView.bounds
        canvasView.layer.addSublayer(gridLayer)
        scrollView.addSubview(canvasView)

        let draft = DraftTetherView(frame: CGRect(origin: .zero, size: canvasSize))
        canvasView.addSubview(draft)
        draftTetherView = draft
    }

    private func buildHintLabel() {
        hintLabel.text = "Tap + Node to add · Drag nodes to move · Drag port → to connect"
        hintLabel.font = PrismTheme.Glyph.corpus(11)
        hintLabel.textColor = PrismTheme.Pigment.mist
        hintLabel.textAlignment = .center
        view.addSubview(hintLabel)
    }

    private func layoutViews() {
        let safeTop    = view.safeAreaInsets.top
        let w          = view.bounds.width
        let h          = view.bounds.height
        let headerH: CGFloat = 56

        headerView.frame = CGRect(x: 0, y: 0, width: w, height: headerH + safeTop)
        headerSep.frame  = CGRect(x: 0, y: headerH + safeTop - 1, width: w, height: 1)
        titleLabel.frame = CGRect(x: 20, y: safeTop + 14, width: 110, height: 28)
        let clearW: CGFloat = 44
        let addW:   CGFloat = 80
        let tplW:   CGFloat = 80
        clearButton.frame      = CGRect(x: w - clearW - 8,                y: safeTop + 12, width: clearW, height: 32)
        addNodeButton.frame    = CGRect(x: w - clearW - addW - 16,        y: safeTop + 12, width: addW,   height: 32)
        templatesButton.frame  = CGRect(x: w - clearW - addW - tplW - 24, y: safeTop + 12, width: tplW,   height: 32)
        let tabBarTop = h - 90
        nodeCountBadge.frame = CGRect(x: 0, y: tabBarTop - 30 - 20, width: w, height: 20)

        scrollView.frame = CGRect(x: 0, y: headerH + safeTop, width: w,
                                  height: h - headerH - safeTop - 90)

        hintLabel.frame = CGRect(x: 0, y: h - 125, width: w, height: 16)
    }

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async { self?.reloadCanvas() }
        }
    }

    func reloadCanvas() {
        guard scrollView.bounds.width > 0 else { return }
        tetherViews.forEach { $0.value.removeFromSuperview() }
        tetherViews.removeAll()

        let currentIds = Set(viewModel.nodes.map { $0.identifier })
        let existingIds = Set(nodeViews.keys)

        existingIds.subtracting(currentIds).forEach { id in
            nodeViews[id]?.removeFromSuperview()
            nodeViews.removeValue(forKey: id)
        }

        for node in viewModel.nodes {
            if nodeViews[node.identifier] == nil {
                let nv = NexusNodeView(node: node)
                nv.onTap          = { [weak self] n in self?.showNodeEditor(n) }
                nv.onDragMoved    = { [weak self] nv, _ in
                    self?.viewModel.updateNodePosition(nv.node.identifier, position: nv.frame.origin)
                    self?.redrawTethers()
                }
                nv.onDragEnded    = { [weak self] nv in
                    self?.viewModel.updateNodePosition(nv.node.identifier, position: nv.frame.origin)
                }
                nv.onConnectionDrag = { [weak self] origin, pt in self?.handleConnectionDrag(from: origin, to: pt) }
                nv.onConnectionEnd  = { [weak self] origin, pt in self?.handleConnectionEnd(from: origin, at: pt) }
                canvasView.addSubview(nv)
                nodeViews[node.identifier] = nv
            } else {
                nodeViews[node.identifier]?.node = node
                nodeViews[node.identifier]?.frame.origin = node.canvasPosition
            }
        }

        redrawTethers()
        nodeCountBadge.text = "\(viewModel.nodes.count) nodes"
        draftTetherView.map { canvasView.bringSubviewToFront($0) }
    }

    private func redrawTethers() {
        tetherViews.forEach { $0.value.removeFromSuperview() }
        tetherViews.removeAll()

        for tether in viewModel.tethers {
            guard let originView = nodeViews[tether.originNodeId],
                  let destView   = nodeViews[tether.destinationNodeId] else { continue }

            let originPt = CGPoint(x: originView.frame.maxX - 10, y: originView.frame.midY)
            let destPt   = CGPoint(x: destView.frame.minX  + 10, y: destView.frame.midY)

            let tv = TetherLineView(tether: tether, from: originPt, to: destPt)
            tv.frame = canvasView.bounds
            canvasView.insertSubview(tv, at: 1)
            tv.redraw()
            tetherViews[tether.identifier] = tv

            let tap = UITapGestureRecognizer(target: self, action: #selector(tetherTapped(_:)))
            tv.addGestureRecognizer(tap)
            tv.isUserInteractionEnabled = true
            tv.tag = viewModel.tethers.firstIndex(where: { $0.identifier == tether.identifier }) ?? 0
        }
        nodeViews.values.forEach { canvasView.bringSubviewToFront($0) }
        draftTetherView.map { canvasView.bringSubviewToFront($0) }
    }

    private func handleConnectionDrag(from originView: NexusNodeView, to point: CGPoint) {
        draftOriginNodeView = originView
        let startPt = CGPoint(x: originView.frame.maxX - 10, y: originView.frame.midY)
        draftTetherView?.startPoint = startPt
        draftTetherView?.endPoint = point
    }

    private func handleConnectionEnd(from originView: NexusNodeView, at point: CGPoint) {
        // Always erase the draft line first – prevents residual ghost lines
        draftTetherView?.clearPath()
        draftOriginNodeView = nil

        for (id, nv) in nodeViews {
            guard id != originView.node.identifier else { continue }
            if nv.frame.contains(point) {
                showTetherTypePicker(from: originView.node.identifier, to: id)
                return
            }
        }
    }

    // MARK: - Actions
    @objc private func showAddNodePicker() {
        let variants = NexusVariant.allCases
        let sheet = NodeTypePickerSheet(variants: variants) { [weak self] variant in
            guard let self = self else { return }
            let cx = self.scrollView.contentOffset.x + self.scrollView.bounds.midX
            let cy = self.scrollView.contentOffset.y + self.scrollView.bounds.midY
            let pos = CGPoint(x: CGFloat.random(in: cx-80...cx+80),
                              y: CGFloat.random(in: cy-80...cy+80))
            self.viewModel.addNode(variant: variant, at: pos)
        }
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle   = .crossDissolve
        present(sheet, animated: true)
    }

    @objc private func showPresetGallery() {
        PresetGalleryViewController.present(on: self) { [weak self] preset in
            guard let self = self else { return }
            BezelDialog.present(
                on: self,
                title: "Load Preset",
                message: "Load \"\(preset.designation)\"? Current canvas will be replaced.",
                variant: .confirm(onConfirm: { [weak self] in
                    self?.viewModel.loadPreset(preset)
                }),
                accentColor: preset.accentColor
            )
        }
    }

    @objc private func confirmClearAll() {
        BezelDialog.present(
            on: self, title: "Clear All",
            message: "Remove all nodes and connections?",
            variant: .confirm(onConfirm: { [weak self] in self?.viewModel.clearAll() }),
            accentColor: PrismTheme.Pigment.crimson
        )
    }

    @objc private func tetherTapped(_ gesture: UITapGestureRecognizer) {
        let idx = gesture.view?.tag ?? 0
        guard idx < viewModel.tethers.count else { return }
        let tether = viewModel.tethers[idx]
        BezelDialog.present(
            on: self, title: "Remove Connection",
            message: "Delete this \(tether.variant.rawValue) connection?",
            variant: .confirm(onConfirm: { [weak self] in self?.viewModel.removeTether(tether.identifier) }),
            accentColor: PrismTheme.TetherPigment.exclusiveHue
        )
    }

    private func showNodeEditor(_ node: NexusNode) {
        let editor = NodeEditorViewController(node: node)
        editor.onSave   = { [weak self] updated in self?.viewModel.updateNode(updated) }
        editor.onDelete = { [weak self] id      in self?.viewModel.removeNode(id) }
        editor.modalPresentationStyle = .overFullScreen
        editor.modalTransitionStyle   = .crossDissolve
        present(editor, animated: true)
    }

    private func showTetherTypePicker(from: String, to: String) {
        let picker = TetherTypePickerSheet { [weak self] variant in
            self?.viewModel.addTether(from: from, to: to, variant: variant)
        }
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle   = .crossDissolve
        present(picker, animated: true)
    }
}

extension WorkshopViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { canvasView }
}

private final class GridPatternLayer: CALayer {
    override init() {
        super.init()
        setNeedsDisplay()
    }
    override init(layer: Any) { super.init(layer: layer) }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(in ctx: CGContext) {
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.04).cgColor)
        ctx.setLineWidth(0.5)
        let step: CGFloat = 40
        var x: CGFloat = 0
        while x <= bounds.width {
            ctx.move(to: CGPoint(x: x, y: 0)); ctx.addLine(to: CGPoint(x: x, y: bounds.height)); x += step
        }
        var y: CGFloat = 0
        while y <= bounds.height {
            ctx.move(to: CGPoint(x: 0, y: y)); ctx.addLine(to: CGPoint(x: bounds.width, y: y)); y += step
        }
        ctx.strokePath()
    }
}
