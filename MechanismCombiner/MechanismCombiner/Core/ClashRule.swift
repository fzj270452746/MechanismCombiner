import Foundation

enum ClashResolution: String, CaseIterable, Codable {
    case precedence = "Priority"
    case supplant   = "Override"
    case nullify    = "Disable"
}

// MARK: - Clash Rule
struct ClashRule: Codable {
    let identifier: String
    var anchorNodeId: String
    var rivalNodeId: String
    var resolution: ClashResolution
    var precedenceRank: Int

    init(
        identifier: String = UUID().uuidString,
        anchorNodeId: String,
        rivalNodeId: String,
        resolution: ClashResolution = .precedence,
        precedenceRank: Int = 1
    ) {
        self.identifier = identifier
        self.anchorNodeId = anchorNodeId
        self.rivalNodeId = rivalNodeId
        self.resolution = resolution
        self.precedenceRank = precedenceRank
    }
}
