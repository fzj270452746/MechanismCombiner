import UIKit

final class BezelDialog: UIView {

    enum DialogVariant {
        case confirm(onConfirm: () -> Void)
        case input(placeholder: String, onConfirm: (String) -> Void)
        case alert
    }

    private let backdropView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let accentBar = UIView()
    private var inputField: UITextField?
    private var confirmButton: GlowButton?
    private var cancelButton: UIButton?

    private var variant: DialogVariant = .alert

    static func present(
        on viewController: UIViewController,
        title: String,
        message: String,
        variant: DialogVariant,
        accentColor: UIColor = PrismTheme.Pigment.nebula
    ) {
        let dialog = BezelDialog()
        dialog.configure(title: title, message: message, variant: variant, accentColor: accentColor)
        dialog.showOn(viewController.view)
    }

    private func configure(title: String, message: String, variant: DialogVariant, accentColor: UIColor) {
        self.variant = variant
        setupBackdrop()
        setupContainer(accentColor: accentColor)
        titleLabel.text = title
        messageLabel.text = message
        setupButtons(variant: variant, accentColor: accentColor)
        if case .input(let placeholder, _) = variant {
            setupInputField(placeholder: placeholder, accentColor: accentColor)
        }
    }

    private func setupBackdrop() {
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backdropView.frame = UIScreen.main.bounds
        addSubview(backdropView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        backdropView.addGestureRecognizer(tap)
    }

    private func setupContainer(accentColor: UIColor) {
        containerView.backgroundColor = PrismTheme.Pigment.cavern
        containerView.layer.cornerRadius = PrismTheme.Radius.xl
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = accentColor.withAlphaComponent(0.4).cgColor
        containerView.layer.shadowColor = accentColor.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOffset = .zero
        addSubview(containerView)

        accentBar.backgroundColor = accentColor
        accentBar.layer.cornerRadius = 2
        containerView.addSubview(accentBar)

        titleLabel.font = PrismTheme.Glyph.headline(18)
        titleLabel.textColor = PrismTheme.Pigment.ivory
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)

        messageLabel.font = PrismTheme.Glyph.corpus(14)
        messageLabel.textColor = PrismTheme.Pigment.mist
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        containerView.addSubview(messageLabel)
    }

    private func setupInputField(placeholder: String, accentColor: UIColor) {
        let field = UITextField()
        field.backgroundColor = PrismTheme.Pigment.vault
        field.textColor = PrismTheme.Pigment.ivory
        field.font = PrismTheme.Glyph.corpus(15)
        field.layer.cornerRadius = PrismTheme.Radius.sm
        field.layer.borderWidth = 1
        field.layer.borderColor = accentColor.withAlphaComponent(0.5).cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: PrismTheme.Pigment.mist]
        )
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
        containerView.addSubview(field)
        self.inputField = field
    }

    private func setupButtons(variant: DialogVariant, accentColor: UIColor) {
        let confirmBtn = GlowButton(
            title: "Confirm",
            gradientColors: [accentColor.cgColor, accentColor.withAlphaComponent(0.7).cgColor],
            glowColor: accentColor
        )
        confirmBtn.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        containerView.addSubview(confirmBtn)
        self.confirmButton = confirmBtn

        if case .alert = variant { return }

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(PrismTheme.Pigment.mist, for: .normal)
        cancelBtn.titleLabel?.font = PrismTheme.Glyph.corpus(15)
        cancelBtn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        containerView.addSubview(cancelBtn)
        self.cancelButton = cancelBtn
    }

    private func showOn(_ parentView: UIView) {
        frame = parentView.bounds
        parentView.addSubview(self)

        let screenW = parentView.bounds.width
        let containerW = min(screenW - 48, 340)
        let hasInput = inputField != nil
        let hasCancel = cancelButton != nil
        let containerH: CGFloat = hasInput ? 260 : (hasCancel ? 220 : 180)

        containerView.frame = CGRect(
            x: (parentView.bounds.width - containerW) / 2,
            y: (parentView.bounds.height - containerH) / 2,
            width: containerW,
            height: containerH
        )

        let pad: CGFloat = 20
        accentBar.frame = CGRect(x: containerW / 2 - 20, y: 16, width: 40, height: 4)
        titleLabel.frame = CGRect(x: pad, y: 32, width: containerW - pad * 2, height: 24)
        messageLabel.frame = CGRect(x: pad, y: 64, width: containerW - pad * 2, height: 50)

        if let field = inputField {
            field.frame = CGRect(x: pad, y: 122, width: containerW - pad * 2, height: 44)
        }

        let btnY: CGFloat = hasInput ? 178 : 130
        let btnW = hasCancel ? (containerW - pad * 2 - 12) / 2 : containerW - pad * 2
        confirmButton?.frame = CGRect(x: pad, y: btnY, width: btnW, height: 44)
        if hasCancel {
            cancelButton?.frame = CGRect(x: pad + btnW + 12, y: btnY, width: btnW, height: 44)
        }

        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        backdropView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.containerView.transform = .identity
            self.backdropView.alpha = 1
        }
    }

    @objc private func handleConfirm() {
        switch variant {
        case .confirm(let onConfirm):
            dismissSelf()
            onConfirm()
        case .input(_, let onConfirm):
            let text = inputField?.text ?? ""
            dismissSelf()
            onConfirm(text)
        case .alert:
            dismissSelf()
        }
    }

    @objc private func dismissSelf() {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.backdropView.alpha = 0
        }) { _ in self.removeFromSuperview() }
    }
}
