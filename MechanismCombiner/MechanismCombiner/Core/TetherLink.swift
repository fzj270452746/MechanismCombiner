import UIKit

enum TetherVariant: String, CaseIterable, Codable {
    case ignition  = "Trigger"
    case amplify   = "Boost"
    case repulse   = "Exclusive"

    var pigment: UIColor {
        switch self {
        case .ignition: return PrismTheme.TetherPigment.triggerHue
        case .amplify:  return PrismTheme.TetherPigment.boostHue
        case .repulse:  return PrismTheme.TetherPigment.exclusiveHue
        }
    }

    var dashPattern: [NSNumber] {
        switch self {
        case .ignition: return []
        case .amplify:  return [8, 4]
        case .repulse:  return [4, 4]
        }
    }

    var descriptor: String {
        switch self {
        case .ignition: return "Triggers activation"
        case .amplify:  return "Boosts reward"
        case .repulse:  return "Mutually exclusive"
        }
    }
}

// MARK: - Tether Link
struct TetherLink: Codable {
    let identifier: String
    var originNodeId: String
    var destinationNodeId: String
    var variant: TetherVariant
    var amplitudeFactor: Double   // used for Boost type

    init(
        identifier: String = UUID().uuidString,
        originNodeId: String,
        destinationNodeId: String,
        variant: TetherVariant,
        amplitudeFactor: Double = 1.0
    ) {
        self.identifier = identifier
        self.originNodeId = originNodeId
        self.destinationNodeId = destinationNodeId
        self.variant = variant
        self.amplitudeFactor = amplitudeFactor
    }
}
