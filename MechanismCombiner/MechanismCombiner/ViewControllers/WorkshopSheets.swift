import UIKit

final class NodeTypePickerSheet: UIViewController {

    private let variants: [NexusVariant]
    private let onSelect: (NexusVariant) -> Void

    private let sheetView = UIView()
    private let titleLabel = UILabel()

    init(variants: [NexusVariant], onSelect: @escaping (NexusVariant) -> Void) {
        self.variants = variants
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        setupSheet()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.sheetView.transform = .identity
        }
    }

    private func setupSheet() {
        let w = min(view.bounds.width - 32, 360)
        let h: CGFloat = CGFloat(variants.count) * 72 + 80
        sheetView.frame = CGRect(x: (view.bounds.width - w) / 2, y: (view.bounds.height - h) / 2, width: w, height: h)
        sheetView.backgroundColor = PrismTheme.Pigment.cavern
        sheetView.layer.cornerRadius = PrismTheme.Radius.xl
        sheetView.layer.borderWidth = 1
        sheetView.layer.borderColor = PrismTheme.Pigment.nebula.withAlphaComponent(0.3).cgColor
        sheetView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        view.addSubview(sheetView)

        titleLabel.text = "Choose Node Type"
        titleLabel.font = PrismTheme.Glyph.headline(17)
        titleLabel.textColor = PrismTheme.Pigment.ivory
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 20, width: w, height: 24)
        sheetView.addSubview(titleLabel)

        for (idx, variant) in variants.enumerated() {
            let cell = buildVariantCell(variant: variant, width: w, y: 60 + CGFloat(idx) * 72)
            sheetView.addSubview(cell)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSheet))
        view.addGestureRecognizer(tap)
        let sheetTap = UITapGestureRecognizer(target: nil, action: nil)
        sheetView.addGestureRecognizer(sheetTap)
    }

    private func buildVariantCell(variant: NexusVariant, width: CGFloat, y: CGFloat) -> UIView {
        let cell = UIView(frame: CGRect(x: 12, y: y, width: width - 24, height: 64))
        cell.backgroundColor = PrismTheme.Pigment.vault
        cell.layer.cornerRadius = PrismTheme.Radius.md
        cell.layer.borderWidth = 1
        cell.layer.borderColor = variant.pigment.withAlphaComponent(0.4).cgColor

        let gradLayer = CAGradientLayer()
        gradLayer.frame = CGRect(x: 0, y: 0, width: 60, height: 64)
        gradLayer.colors = variant.gradientColors
        gradLayer.cornerRadius = PrismTheme.Radius.md
        gradLayer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        cell.layer.insertSublayer(gradLayer, at: 0)

        let iconImg = UIImageView(image: UIImage(systemName: variant.sfSymbol))
        iconImg.tintColor = .white
        iconImg.frame = CGRect(x: 18, y: 18, width: 28, height: 28)
        iconImg.contentMode = .scaleAspectFit
        cell.addSubview(iconImg)

        let nameLabel = UILabel()
        nameLabel.text = variant.rawValue
        nameLabel.font = PrismTheme.Glyph.subhead(16)
        nameLabel.textColor = PrismTheme.Pigment.ivory
        nameLabel.frame = CGRect(x: 72, y: 14, width: width - 100, height: 22)
        cell.addSubview(nameLabel)

        let descLabel = UILabel()
        descLabel.text = variantDescription(variant)
        descLabel.font = PrismTheme.Glyph.corpus(12)
        descLabel.textColor = PrismTheme.Pigment.mist
        descLabel.frame = CGRect(x: 72, y: 36, width: width - 100, height: 16)
        cell.addSubview(descLabel)

        let btn = UIButton(frame: cell.bounds)
        btn.tag = NexusVariant.allCases.firstIndex(of: variant) ?? 0
        btn.addTarget(self, action: #selector(variantSelected(_:)), for: .touchUpInside)
        cell.addSubview(btn)
        return cell
    }

    private func variantDescription(_ variant: NexusVariant) -> String {
        switch variant {
        case .wildform:    return "Substitutes symbols, boosts wins"
        case .scatterform: return "Triggers free spins anywhere"
        case .bonusform:   return "Activates bonus round"
        case .ampliform:   return "Multiplies reward value"
        }
    }

    @objc private func variantSelected(_ sender: UIButton) {
        let variant = NexusVariant.allCases[sender.tag]
        dismiss(animated: false)
        onSelect(variant)
    }

    @objc private func dismissSheet() { dismiss(animated: false) }
}

final class TetherTypePickerSheet: UIViewController {

    private let onSelect: (TetherVariant) -> Void
    private let sheetView = UIView()

    init(onSelect: @escaping (TetherVariant) -> Void) {
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        setupSheet()
    }

    private func setupSheet() {
        let variants = TetherVariant.allCases
        let w = min(view.bounds.width - 32, 360)
        let h: CGFloat = CGFloat(variants.count) * 68 + 80
        sheetView.frame = CGRect(x: (view.bounds.width - w) / 2, y: (view.bounds.height - h) / 2, width: w, height: h)
        sheetView.backgroundColor = PrismTheme.Pigment.cavern
        sheetView.layer.cornerRadius = PrismTheme.Radius.xl
        sheetView.layer.borderWidth = 1
        sheetView.layer.borderColor = PrismTheme.Pigment.aurora.withAlphaComponent(0.3).cgColor
        view.addSubview(sheetView)

        let title = UILabel()
        title.text = "Connection Type"
        title.font = PrismTheme.Glyph.headline(17)
        title.textColor = PrismTheme.Pigment.ivory
        title.textAlignment = .center
        title.frame = CGRect(x: 0, y: 20, width: w, height: 24)
        sheetView.addSubview(title)

        for (idx, variant) in variants.enumerated() {
            let cell = buildCell(variant: variant, width: w, y: 58 + CGFloat(idx) * 68)
            sheetView.addSubview(cell)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSheet))
        view.addGestureRecognizer(tap)
    }

    private func buildCell(variant: TetherVariant, width: CGFloat, y: CGFloat) -> UIView {
        let cell = UIView(frame: CGRect(x: 12, y: y, width: width - 24, height: 60))
        cell.backgroundColor = PrismTheme.Pigment.vault
        cell.layer.cornerRadius = PrismTheme.Radius.md
        cell.layer.borderWidth = 1.5
        cell.layer.borderColor = variant.pigment.withAlphaComponent(0.5).cgColor

        let dot = UIView(frame: CGRect(x: 16, y: 20, width: 20, height: 20))
        dot.backgroundColor = variant.pigment
        dot.layer.cornerRadius = 10
        dot.layer.shadowColor = variant.pigment.cgColor
        dot.layer.shadowOpacity = 0.7
        dot.layer.shadowRadius = 6
        cell.addSubview(dot)

        let nameLabel = UILabel()
        nameLabel.text = variant.rawValue
        nameLabel.font = PrismTheme.Glyph.subhead(15)
        nameLabel.textColor = PrismTheme.Pigment.ivory
        nameLabel.frame = CGRect(x: 48, y: 10, width: width - 76, height: 20)
        cell.addSubview(nameLabel)

        let descLabel = UILabel()
        descLabel.text = variant.descriptor
        descLabel.font = PrismTheme.Glyph.corpus(12)
        descLabel.textColor = PrismTheme.Pigment.mist
        descLabel.frame = CGRect(x: 48, y: 30, width: width - 76, height: 16)
        cell.addSubview(descLabel)

        let btn = UIButton(frame: cell.bounds)
        btn.tag = TetherVariant.allCases.firstIndex(of: variant) ?? 0
        btn.addTarget(self, action: #selector(variantSelected(_:)), for: .touchUpInside)
        cell.addSubview(btn)
        return cell
    }

    @objc private func variantSelected(_ sender: UIButton) {
        let variant = TetherVariant.allCases[sender.tag]
        dismiss(animated: false)
        onSelect(variant)
    }

    @objc private func dismissSheet() { dismiss(animated: false) }
}

final class NodeEditorViewController: UIViewController {

    var onSave: ((NexusNode) -> Void)?
    var onDelete: ((String) -> Void)?

    private var node: NexusNode
    private let sheetView = UIView()
    private let nameField = UITextField()
    private let probSlider = UISlider()
    private let probValueLabel = UILabel()
    private let yieldSlider = UISlider()
    private let yieldValueLabel = UILabel()

    init(node: NexusNode) {
        self.node = node
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        setupSheet()
    }

    private func setupSheet() {
        let w = min(view.bounds.width - 32, 360)
        let h: CGFloat = 420
        sheetView.frame = CGRect(x: (view.bounds.width - w) / 2, y: (view.bounds.height - h) / 2, width: w, height: h)
        sheetView.backgroundColor = PrismTheme.Pigment.cavern
        sheetView.layer.cornerRadius = PrismTheme.Radius.xl
        sheetView.layer.borderWidth = 1
        sheetView.layer.borderColor = node.variant.pigment.withAlphaComponent(0.4).cgColor
        view.addSubview(sheetView)

        var y: CGFloat = 20

        // Color accent bar
        let bar = UIView(frame: CGRect(x: w / 2 - 24, y: y, width: 48, height: 4))
        bar.backgroundColor = node.variant.pigment
        bar.layer.cornerRadius = 2
        sheetView.addSubview(bar)
        y += 24

        let titleLabel = UILabel(frame: CGRect(x: 20, y: y, width: w - 40, height: 24))
        titleLabel.text = "Edit \(node.variant.rawValue) Node"
        titleLabel.font = PrismTheme.Glyph.headline(17)
        titleLabel.textColor = PrismTheme.Pigment.ivory
        sheetView.addSubview(titleLabel)
        y += 38

        // Name field
        addSectionLabel("Name", y: y, width: w)
        y += 22
        nameField.frame = CGRect(x: 20, y: y, width: w - 40, height: 40)
        nameField.text = node.designation
        styleTextField(nameField, accentColor: node.variant.pigment)
        sheetView.addSubview(nameField)
        y += 52

        // Probability slider
        addSectionLabel("Trigger Probability", y: y, width: w)
        y += 22
        probSlider.frame = CGRect(x: 20, y: y, width: w - 80, height: 28)
        probSlider.minimumValue = 0.01
        probSlider.maximumValue = 1.0
        probSlider.value = Float(node.ignitionProbability)
        probSlider.tintColor = node.variant.pigment
        probSlider.addTarget(self, action: #selector(probChanged), for: .valueChanged)
        sheetView.addSubview(probSlider)

        probValueLabel.frame = CGRect(x: w - 56, y: y, width: 48, height: 28)
        probValueLabel.text = String(format: "%.0f%%", node.ignitionProbability * 100)
        probValueLabel.font = PrismTheme.Glyph.mono(13)
        probValueLabel.textColor = node.variant.pigment
        probValueLabel.textAlignment = .right
        sheetView.addSubview(probValueLabel)
        y += 48

        // Yield multiplier slider
        addSectionLabel("Yield Multiplier", y: y, width: w)
        y += 22
        yieldSlider.frame = CGRect(x: 20, y: y, width: w - 80, height: 28)
        yieldSlider.minimumValue = 0.5
        yieldSlider.maximumValue = 10.0
        yieldSlider.value = Float(node.yieldMultiplier)
        yieldSlider.tintColor = PrismTheme.Pigment.aurora
        yieldSlider.addTarget(self, action: #selector(yieldChanged), for: .valueChanged)
        sheetView.addSubview(yieldSlider)

        yieldValueLabel.frame = CGRect(x: w - 56, y: y, width: 48, height: 28)
        yieldValueLabel.text = String(format: "%.1fx", node.yieldMultiplier)
        yieldValueLabel.font = PrismTheme.Glyph.mono(13)
        yieldValueLabel.textColor = PrismTheme.Pigment.aurora
        yieldValueLabel.textAlignment = .right
        sheetView.addSubview(yieldValueLabel)
        y += 56

        // Buttons
        let saveBtn = GlowButton(
            title: "Save",
            gradientColors: node.variant.gradientColors,
            glowColor: node.variant.pigment
        )
        saveBtn.frame = CGRect(x: 20, y: y, width: (w - 52) / 2, height: 44)
        saveBtn.addTarget(self, action: #selector(saveNode), for: .touchUpInside)
        sheetView.addSubview(saveBtn)

        let deleteBtn = UIButton(type: .system)
        deleteBtn.setTitle("Delete", for: .normal)
        deleteBtn.setTitleColor(PrismTheme.Pigment.crimson, for: .normal)
        deleteBtn.titleLabel?.font = PrismTheme.Glyph.subhead(15)
        deleteBtn.frame = CGRect(x: 20 + (w - 52) / 2 + 12, y: y, width: (w - 52) / 2, height: 44)
        deleteBtn.layer.borderWidth = 1
        deleteBtn.layer.borderColor = PrismTheme.Pigment.crimson.withAlphaComponent(0.5).cgColor
        deleteBtn.layer.cornerRadius = PrismTheme.Radius.md
        deleteBtn.addTarget(self, action: #selector(deleteNode), for: .touchUpInside)
        sheetView.addSubview(deleteBtn)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissEditor))
        view.addGestureRecognizer(tap)
        let sheetTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        sheetView.addGestureRecognizer(sheetTap)
    }

    private func addSectionLabel(_ text: String, y: CGFloat, width: CGFloat) {
        let label = UILabel(frame: CGRect(x: 20, y: y, width: width - 40, height: 18))
        label.text = text
        label.font = PrismTheme.Glyph.subhead(12)
        label.textColor = PrismTheme.Pigment.mist
        sheetView.addSubview(label)
    }

    private func styleTextField(_ field: UITextField, accentColor: UIColor) {
        field.backgroundColor = PrismTheme.Pigment.vault
        field.textColor = PrismTheme.Pigment.ivory
        field.font = PrismTheme.Glyph.corpus(15)
        field.layer.cornerRadius = PrismTheme.Radius.sm
        field.layer.borderWidth = 1
        field.layer.borderColor = accentColor.withAlphaComponent(0.5).cgColor
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftView = pad
        field.leftViewMode = .always
    }

    @objc private func probChanged() {
        probValueLabel.text = String(format: "%.0f%%", probSlider.value * 100)
    }

    @objc private func yieldChanged() {
        yieldValueLabel.text = String(format: "%.1fx", yieldSlider.value)
    }

    @objc private func saveNode() {
        node.designation = nameField.text?.isEmpty == false ? nameField.text! : node.designation
        node.ignitionProbability = Double(probSlider.value)
        node.yieldMultiplier = Double(yieldSlider.value)
        dismiss(animated: false)
        onSave?(node)
    }

    @objc private func deleteNode() {
        dismiss(animated: false)
        onDelete?(node.identifier)
    }

    @objc private func dismissEditor() { dismiss(animated: false) }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
