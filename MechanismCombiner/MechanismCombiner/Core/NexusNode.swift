import UIKit

enum NexusVariant: String, CaseIterable, Codable {
    case wildform    = "Wild"
    case scatterform = "Scatter"
    case bonusform   = "Bonus"
    case ampliform   = "Multiplier"

    var pigment: UIColor {
        switch self {
        case .wildform:    return PrismTheme.NodePigment.wildHue
        case .scatterform: return PrismTheme.NodePigment.scatterHue
        case .bonusform:   return PrismTheme.NodePigment.bonusHue
        case .ampliform:   return PrismTheme.NodePigment.multiplierHue
        }
    }

    var glyphSymbol: String {
        switch self {
        case .wildform:    return "W"
        case .scatterform: return "S"
        case .bonusform:   return "B"
        case .ampliform:   return "M"
        }
    }

    var sfSymbol: String {
        switch self {
        case .wildform:    return "sparkles"
        case .scatterform: return "circle.grid.3x3.fill"
        case .bonusform:   return "gift.fill"
        case .ampliform:   return "multiply.circle.fill"
        }
    }

    var gradientColors: [CGColor] {
        switch self {
        case .wildform:    return PrismTheme.Gradient.nebulaAurora
        case .scatterform: return [PrismTheme.Pigment.aurora.cgColor, UIColor(hex: "#0099CC").cgColor]
        case .bonusform:   return PrismTheme.Gradient.solarEmber
        case .ampliform:   return PrismTheme.Gradient.verdantAurora
        }
    }
}

// MARK: - Nexus Node
struct NexusNode: Codable {
    let identifier: String
    var designation: String
    var variant: NexusVariant
    var ignitionProbability: Double   // 0.0 – 1.0
    var yieldMultiplier: Double       // reward multiplier
    var canvasPosition: CGPoint       // position on canvas

    init(
        identifier: String = UUID().uuidString,
        designation: String,
        variant: NexusVariant,
        ignitionProbability: Double = 0.05,
        yieldMultiplier: Double = 1.5,
        canvasPosition: CGPoint = .zero
    ) {
        self.identifier = identifier
        self.designation = designation
        self.variant = variant
        self.ignitionProbability = ignitionProbability
        self.yieldMultiplier = yieldMultiplier
        self.canvasPosition = canvasPosition
    }

    // CGPoint isn't Codable natively
    enum CodingKeys: String, CodingKey {
        case identifier, designation, variant, ignitionProbability, yieldMultiplier, posX, posY
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        identifier           = try c.decode(String.self,       forKey: .identifier)
        designation          = try c.decode(String.self,       forKey: .designation)
        variant              = try c.decode(NexusVariant.self, forKey: .variant)
        ignitionProbability  = try c.decode(Double.self,       forKey: .ignitionProbability)
        yieldMultiplier      = try c.decode(Double.self,       forKey: .yieldMultiplier)
        let x                = try c.decode(CGFloat.self,      forKey: .posX)
        let y                = try c.decode(CGFloat.self,      forKey: .posY)
        canvasPosition       = CGPoint(x: x, y: y)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(identifier,          forKey: .identifier)
        try c.encode(designation,         forKey: .designation)
        try c.encode(variant,             forKey: .variant)
        try c.encode(ignitionProbability, forKey: .ignitionProbability)
        try c.encode(yieldMultiplier,     forKey: .yieldMultiplier)
        try c.encode(canvasPosition.x,    forKey: .posX)
        try c.encode(canvasPosition.y,    forKey: .posY)
    }
}
