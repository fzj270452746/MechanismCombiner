import UIKit

struct PresetBundle {
    let designation: String
    let synopsis: String
    let categoryTag: String
    let accentColor: UIColor
    let sfSymbol: String
    let nodes: [NexusNode]
    let tethers: [TetherLink]
}

enum PresetVault {

    static let catalogue: [PresetBundle] = [
        cascadeTriggerChain(),
        riskRewardBalance(),
        amplifierNetwork(),
        scatterFreeSpin(),
        compoundMultiplier()
    ]

    private static func cascadeTriggerChain() -> PresetBundle {
        let n1 = NexusNode(designation: "Trigger A",    variant: .scatterform, ignitionProbability: 0.08, yieldMultiplier: 1.0, canvasPosition: CGPoint(x: 120, y: 160))
        let n2 = NexusNode(designation: "Reward Gate",  variant: .bonusform,   ignitionProbability: 0.04, yieldMultiplier: 4.0, canvasPosition: CGPoint(x: 320, y: 160))
        let n3 = NexusNode(designation: "Amplifier",    variant: .ampliform,   ignitionProbability: 0.15, yieldMultiplier: 2.5, canvasPosition: CGPoint(x: 520, y: 160))
        let n4 = NexusNode(designation: "Wild Bridge",  variant: .wildform,    ignitionProbability: 0.20, yieldMultiplier: 1.5, canvasPosition: CGPoint(x: 320, y: 320))

        let t1 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n2.identifier, variant: .ignition,  amplitudeFactor: 1.0)
        let t2 = TetherLink(originNodeId: n2.identifier, destinationNodeId: n3.identifier, variant: .ignition,  amplitudeFactor: 1.0)
        let t3 = TetherLink(originNodeId: n4.identifier, destinationNodeId: n3.identifier, variant: .amplify,   amplitudeFactor: 1.8)

        return PresetBundle(
            designation: "Cascade Trigger Chain",
            synopsis: "Sequential trigger flow with an amplifier at the end. Great for studying compound activation probability.",
            categoryTag: "Trigger Flow",
            accentColor: PrismTheme.TetherPigment.triggerHue,
            sfSymbol: "arrow.triangle.branch",
            nodes: [n1, n2, n3, n4],
            tethers: [t1, t2, t3]
        )
    }

    private static func riskRewardBalance() -> PresetBundle {
        let n1 = NexusNode(designation: "High Risk",    variant: .scatterform, ignitionProbability: 0.02, yieldMultiplier: 10.0, canvasPosition: CGPoint(x: 150, y: 140))
        let n2 = NexusNode(designation: "Low Risk",     variant: .wildform,    ignitionProbability: 0.30, yieldMultiplier: 1.2,  canvasPosition: CGPoint(x: 150, y: 340))
        let n3 = NexusNode(designation: "Bonus Gate",   variant: .bonusform,   ignitionProbability: 0.05, yieldMultiplier: 6.0,  canvasPosition: CGPoint(x: 450, y: 240))

        let t1 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n3.identifier, variant: .ignition, amplitudeFactor: 1.0)
        let t2 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n2.identifier, variant: .repulse,  amplitudeFactor: 1.0)

        return PresetBundle(
            designation: "Risk-Reward Balance",
            synopsis: "Explores trade-off between high-risk/high-reward and safe/low-reward paths using exclusive connections.",
            categoryTag: "Balance",
            accentColor: PrismTheme.Pigment.solar,
            sfSymbol: "scale.3d",
            nodes: [n1, n2, n3],
            tethers: [t1, t2]
        )
    }

    private static func amplifierNetwork() -> PresetBundle {
        let n1 = NexusNode(designation: "Base Trigger",  variant: .scatterform, ignitionProbability: 0.10, yieldMultiplier: 1.0, canvasPosition: CGPoint(x: 100, y: 240))
        let n2 = NexusNode(designation: "Amp x2",        variant: .ampliform,   ignitionProbability: 0.20, yieldMultiplier: 2.0, canvasPosition: CGPoint(x: 300, y: 140))
        let n3 = NexusNode(designation: "Amp x3",        variant: .ampliform,   ignitionProbability: 0.10, yieldMultiplier: 3.0, canvasPosition: CGPoint(x: 300, y: 340))
        let n4 = NexusNode(designation: "Final Reward",  variant: .bonusform,   ignitionProbability: 0.03, yieldMultiplier: 8.0, canvasPosition: CGPoint(x: 550, y: 240))

        let t1 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n2.identifier, variant: .ignition, amplitudeFactor: 1.0)
        let t2 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n3.identifier, variant: .ignition, amplitudeFactor: 1.0)
        let t3 = TetherLink(originNodeId: n2.identifier, destinationNodeId: n4.identifier, variant: .amplify,  amplitudeFactor: 2.0)
        let t4 = TetherLink(originNodeId: n3.identifier, destinationNodeId: n4.identifier, variant: .amplify,  amplitudeFactor: 3.0)

        return PresetBundle(
            designation: "Amplifier Network",
            synopsis: "Dual amplifier paths feeding into a final reward node. Demonstrates multiplicative stacking effects on RTP.",
            categoryTag: "Multiplier",
            accentColor: PrismTheme.NodePigment.multiplierHue,
            sfSymbol: "arrow.up.right.and.arrow.down.left",
            nodes: [n1, n2, n3, n4],
            tethers: [t1, t2, t3, t4]
        )
    }

    private static func scatterFreeSpin() -> PresetBundle {
        let n1 = NexusNode(designation: "Scatter",      variant: .scatterform, ignitionProbability: 0.05, yieldMultiplier: 2.0, canvasPosition: CGPoint(x: 120, y: 200))
        let n2 = NexusNode(designation: "Free Spin",    variant: .bonusform,   ignitionProbability: 0.10, yieldMultiplier: 3.0, canvasPosition: CGPoint(x: 380, y: 140))
        let n3 = NexusNode(designation: "Wild Boost",   variant: .wildform,    ignitionProbability: 0.25, yieldMultiplier: 1.5, canvasPosition: CGPoint(x: 380, y: 320))
        let n4 = NexusNode(designation: "Multiplier",   variant: .ampliform,   ignitionProbability: 0.12, yieldMultiplier: 2.5, canvasPosition: CGPoint(x: 620, y: 240))

        let t1 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n2.identifier, variant: .ignition, amplitudeFactor: 1.0)
        let t2 = TetherLink(originNodeId: n2.identifier, destinationNodeId: n3.identifier, variant: .ignition, amplitudeFactor: 1.0)
        let t3 = TetherLink(originNodeId: n3.identifier, destinationNodeId: n4.identifier, variant: .amplify,  amplitudeFactor: 2.0)
        let t4 = TetherLink(originNodeId: n2.identifier, destinationNodeId: n4.identifier, variant: .amplify,  amplitudeFactor: 1.5)

        return PresetBundle(
            designation: "Scatter Free-Spin Loop",
            synopsis: "Classic Scatter→FreeSpin→Wild→Multiplier chain. A standard pattern found in many production slot games.",
            categoryTag: "Classic",
            accentColor: PrismTheme.NodePigment.scatterHue,
            sfSymbol: "circle.grid.3x3.fill",
            nodes: [n1, n2, n3, n4],
            tethers: [t1, t2, t3, t4]
        )
    }

    private static func compoundMultiplier() -> PresetBundle {
        let n1 = NexusNode(designation: "Entry Gate",   variant: .wildform,    ignitionProbability: 0.18, yieldMultiplier: 1.0, canvasPosition: CGPoint(x: 100, y: 240))
        let n2 = NexusNode(designation: "Splitter",     variant: .scatterform, ignitionProbability: 0.08, yieldMultiplier: 1.5, canvasPosition: CGPoint(x: 300, y: 140))
        let n3 = NexusNode(designation: "Guard",        variant: .bonusform,   ignitionProbability: 0.04, yieldMultiplier: 5.0, canvasPosition: CGPoint(x: 300, y: 340))
        let n4 = NexusNode(designation: "Amp Core",     variant: .ampliform,   ignitionProbability: 0.10, yieldMultiplier: 4.0, canvasPosition: CGPoint(x: 520, y: 240))

        let t1 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n2.identifier, variant: .ignition,  amplitudeFactor: 1.0)
        let t2 = TetherLink(originNodeId: n1.identifier, destinationNodeId: n3.identifier, variant: .ignition,  amplitudeFactor: 1.0)
        let t3 = TetherLink(originNodeId: n2.identifier, destinationNodeId: n4.identifier, variant: .amplify,   amplitudeFactor: 2.5)
        let t4 = TetherLink(originNodeId: n3.identifier, destinationNodeId: n2.identifier, variant: .repulse,   amplitudeFactor: 1.0)

        return PresetBundle(
            designation: "Compound Multiplier",
            synopsis: "Entry node splits into a competitive pair where one guard suppresses the splitter, creating volatile high-payout events.",
            categoryTag: "Advanced",
            accentColor: PrismTheme.Pigment.ember,
            sfSymbol: "bolt.fill",
            nodes: [n1, n2, n3, n4],
            tethers: [t1, t2, t3, t4]
        )
    }
}
