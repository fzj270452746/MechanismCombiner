import UIKit

enum PrismTheme {
    enum Pigment {
        static let obsidian      = UIColor(hex: "#0A0E1A")
        static let abyss         = UIColor(hex: "#0D1225")
        static let cavern        = UIColor(hex: "#141830")
        static let vault         = UIColor(hex: "#1C2240")
        static let slate         = UIColor(hex: "#252D50")
        static let nebula        = UIColor(hex: "#6C63FF")
        static let aurora        = UIColor(hex: "#00D4FF")
        static let ember         = UIColor(hex: "#FF6B35")
        static let verdant       = UIColor(hex: "#00E5A0")
        static let crimson       = UIColor(hex: "#FF3B6B")
        static let solar         = UIColor(hex: "#FFD700")
        static let mist          = UIColor(hex: "#8892B0")
        static let frost         = UIColor(hex: "#CCD6F6")
        static let ivory         = UIColor(hex: "#E6F1FF")
    }

    enum NodePigment {
        static let wildHue       = UIColor(hex: "#6C63FF")
        static let scatterHue    = UIColor(hex: "#00D4FF")
        static let bonusHue      = UIColor(hex: "#FFD700")
        static let multiplierHue = UIColor(hex: "#00E5A0")
    }

    enum TetherPigment {
        static let triggerHue    = UIColor(hex: "#FF6B35")
        static let boostHue      = UIColor(hex: "#00E5A0")
        static let exclusiveHue  = UIColor(hex: "#FF3B6B")
    }

    enum Glyph {
        static func headline(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .bold)
        }
        static func subhead(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        static func corpus(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .regular)
        }
        static func mono(_ size: CGFloat) -> UIFont {
            UIFont.monospacedSystemFont(ofSize: size, weight: .medium)
        }
    }

    enum Gradient {
        static let nebulaAurora  = [Pigment.nebula.cgColor, Pigment.aurora.cgColor]
        static let emberCrimson  = [Pigment.ember.cgColor, Pigment.crimson.cgColor]
        static let verdantAurora = [Pigment.verdant.cgColor, Pigment.aurora.cgColor]
        static let solarEmber    = [Pigment.solar.cgColor, Pigment.ember.cgColor]
        static let abyssVault    = [Pigment.abyss.cgColor, Pigment.vault.cgColor]
        static let obsidianCavern = [Pigment.obsidian.cgColor, Pigment.cavern.cgColor]
    }

    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 12
        static let lg: CGFloat  = 16
        static let xl: CGFloat  = 24
        static let pill: CGFloat = 999
    }
}

// MARK: - UIColor hex init
extension UIColor {
    convenience init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8)  & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

extension CAGradientLayer {
    static func prismGradient(colors: [CGColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        return layer
    }
}
