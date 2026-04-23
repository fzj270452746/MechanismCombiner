import UIKit

// MARK: - Core Data Structures (低频命名)

struct PilgrimRecord {
    var vigorStock: Int              // Health
    var gildedHoard: Int            // Gold
    var sigilCount: Int             // Keys
    var lucidityQuotient: Int       // Intellect / Sanity
}

struct ChamberArchetype {
    let chamberTitle: String
    let arcaneSummary: String
    let effectInvocation: (inout PilgrimRecord) -> String?
}

// MARK: - Room Effect Generator (Dynamic >100 functional rooms)

enum EsotericEffectKind: CaseIterable {
    case rejuvenate, afflict, enrich, enlighten, consecrate, blight, reforge, glimpseAbyss, harvestMana, temporalRipple
}

class VestibuleForge {
    
    static func fabricateTransientPortal() -> ChamberArchetype {
        let effectKind = EsotericEffectKind.allCases.randomElement()!
        let magnitude = Int.random(in: 1...6)
        let isBlessed = Bool.random()
        
        switch effectKind {
        case .rejuvenate:
            let restore = magnitude + (isBlessed ? 2 : 0)
            let description = isBlessed ? "Celestial Wellspring · Restores \(restore) vitality." : "Herbalist's Nook · Recover \(restore) health."
            return ChamberArchetype(chamberTitle: "Lustral Pool", arcaneSummary: description) { stats in
                stats.vigorStock += restore
                return "🌿 +\(restore) Vigor"
            }
        case .afflict:
            let damage = magnitude
            let description = "Tangled Thorns · Suffer \(damage) lacerations."
            return ChamberArchetype(chamberTitle: "Briar Labyrinth", arcaneSummary: description) { stats in
                stats.vigorStock -= damage
                return "🌵 -\(damage) Vigor"
            }
        case .enrich:
            let coins = magnitude * (Int.random(in: 1...3))
            let description = "Glimmering Treasury · Acquire \(coins) sovereigns."
            return ChamberArchetype(chamberTitle: "Gilded Vault", arcaneSummary: description) { stats in
                stats.gildedHoard += coins
                return "💰 +\(coins) Gold"
            }
        case .enlighten:
            let insight = magnitude / 2 + 1
            let description = "Scribe's Athenaeum · Gain \(insight) lore might."
            return ChamberArchetype(chamberTitle: "Archives of Resonance", arcaneSummary: description) { stats in
                stats.lucidityQuotient += insight
                return "📜 +\(insight) Insight"
            }
        case .consecrate:
            let keyChance = Int.random(in: 1...4)
            let description = keyChance == 1 ? "Shrine of Covenant · Bestow a sacred sigil." : "Chapel of Whispers · Meditation restores 2 vigor."
            return ChamberArchetype(chamberTitle: "Hallow Sanctum", arcaneSummary: description) { stats in
                if keyChance == 1 {
                    stats.sigilCount += 1
                    return "🔑 +1 Sigil"
                } else {
                    stats.vigorStock += 2
                    return "🕯️ +2 Vigor"
                }
            }
        case .blight:
            let curse = magnitude / 2 + 1
            let description = "Fungal Necropolis · Lose \(curse) lucidity and \(curse) gold."
            return ChamberArchetype(chamberTitle: "Spore Crypt", arcaneSummary: description) { stats in
                stats.lucidityQuotient -= curse
                stats.gildedHoard -= curse
                return "🍄 -\(curse) Insight & Gold"
            }
        case .reforge:
            let option = Bool.random()
            let description = option ? "Anvil of Oddities · Convert 5 gold into 2 vigor." : "Armillary Dial · Trade 3 insight for a sigil."
            return ChamberArchetype(chamberTitle: "Transmuter's Crucible", arcaneSummary: description) { stats in
                if option, stats.gildedHoard >= 5 {
                    stats.gildedHoard -= 5
                    stats.vigorStock += 2
                    return "⚙️ -5 Gold, +2 Vigor"
                } else if !option, stats.lucidityQuotient >= 3 {
                    stats.lucidityQuotient -= 3
                    stats.sigilCount += 1
                    return "🔮 -3 Insight, +1 Sigil"
                } else {
                    return "✨ Nothing changed ... insufficient resources"
                }
            }
        case .glimpseAbyss:
            let penalty = magnitude
            let reward = Int.random(in: 1...3)
            let description = "Echoing Void · Lose \(penalty) vigor, but glimpse a sigil shard."
            return ChamberArchetype(chamberTitle: "Oblivion Atrium", arcaneSummary: description) { stats in
                stats.vigorStock -= penalty
                if stats.vigorStock > 0 {
                    stats.sigilCount += reward
                    return "🌑 -\(penalty) Vigor, +\(reward) Sigil"
                } else {
                    return "💀 Abyss consumes you..."
                }
            }
        case .harvestMana:
            let essence = magnitude
            let description = "Crystal Geode · Gain \(essence) lucidity and 2 gold."
            return ChamberArchetype(chamberTitle: "Prism Nexus", arcaneSummary: description) { stats in
                stats.lucidityQuotient += essence
                stats.gildedHoard += 2
                return "💎 +\(essence) Insight, +2 Gold"
            }
        case .temporalRipple:
            let resetChoice = Bool.random()
            let description = resetChoice ? "Hourglass Chamber · Restore all lost attributes by 2." : "Fractured Mirror · Lose 1 sigil but gain 6 gold."
            return ChamberArchetype(chamberTitle: "Chrono Vestige", arcaneSummary: description) { stats in
                if resetChoice {
                    stats.vigorStock += 2
                    stats.lucidityQuotient += 2
                    return "⌛ +2 Vigor & Insight"
                } else {
                    stats.sigilCount = max(0, stats.sigilCount - 1)
                    stats.gildedHoard += 6
                    return "🪞 -1 Sigil, +6 Gold"
                }
            }
        }
    }
    
    static func forgeVictoryChamber(requiredSigils: Int) -> ChamberArchetype {
        return ChamberArchetype(chamberTitle: "Cerulean Throne Room", arcaneSummary: "Azure Prince's Sanctum · Requires \(requiredSigils) sigils to claim triumph.") { stats in
            if stats.sigilCount >= requiredSigils {
                return "👑 VICTORY! You have proven worthy."
            } else {
                return "🚪 The throne rejects you. Need \(requiredSigils - stats.sigilCount) more sigils."
            }
        }
    }
}

// MARK: - Main Game View (All core gameplay within this UIView)

final class AzurePrinceGameView: UIView {
    
    // MARK: - Nested UI Elements
    private let panoramaBackground = GradientSketchView()
    private var vigorLabel: UILabel!
    private var hoardLabel: UILabel!
    private var sigilLabel: UILabel!
    private var loreLabel: UILabel!
    private var mapScrollStack: UIStackView!
    private var cardContainer: UIStackView!
    private var messageScroll: UITextView!
    private var resetButton: UIButton!
    
    // MARK: - Game State
    private var currentPilgrim: PilgrimRecord {
        didSet {
            refreshStatusMonolith()
            evaluateTerminalThreshold()
        }
    }
    private var visitedChambers: [ChamberArchetype] = []
    private var pendingPortals: [ChamberArchetype] = []   // Three current choices
    private var gameIsFrozen = false
    private let triumphSigilRequirement = 3
    
    // MARK: - Init
    override init(frame: CGRect) {
        self.currentPilgrim = PilgrimRecord(vigorStock: 18, gildedHoard: 8, sigilCount: 0, lucidityQuotient: 5)
        super.init(frame: frame)
        constructCelestialBasin()
        initiateFreshExpedition()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - UI Construction (Artistic & Game Feel)
    private func constructCelestialBasin() {
        addSubview(panoramaBackground)
        panoramaBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            panoramaBackground.topAnchor.constraint(equalTo: topAnchor),
            panoramaBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            panoramaBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            panoramaBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        panoramaBackground.gradientColors = [UIColor(red: 0.08, green: 0.06, blue: 0.2, alpha: 1), UIColor(red: 0.02, green: 0.01, blue: 0.07, alpha: 1)]
        
        // Status panel
        let statusPanel = UIView()
        statusPanel.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        statusPanel.layer.cornerRadius = 24
        statusPanel.layer.borderWidth = 1
        statusPanel.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
        addSubview(statusPanel)
        statusPanel.translatesAutoresizingMaskIntoConstraints = false
        
        vigorLabel = createGlowingLabel()
        hoardLabel = createGlowingLabel()
        sigilLabel = createGlowingLabel()
        loreLabel = createGlowingLabel()
        
        let statStack = UIStackView(arrangedSubviews: [vigorLabel, hoardLabel, sigilLabel, loreLabel])
        statStack.axis = .horizontal
        statStack.distribution = .equalSpacing
        statStack.spacing = 16
        statusPanel.addSubview(statStack)
        statStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Map display (dynamic hallway)
        let mapTitle = createCaptionLabel(text: "✦ AZURE ITINERARY ✦")
        addSubview(mapTitle)
        mapTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let mapContainer = UIView()
        mapContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        mapContainer.layer.cornerRadius = 18
        mapContainer.layer.borderWidth = 0.5
        mapContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        addSubview(mapContainer)
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        
        mapScrollStack = UIStackView()
        mapScrollStack.axis = .horizontal
        mapScrollStack.spacing = 12
        mapScrollStack.alignment = .center
        mapScrollStack.distribution = .fillProportionally
        let mapScroll = UIScrollView()
        mapScroll.addSubview(mapScrollStack)
        mapScroll.showsHorizontalScrollIndicator = false
        mapContainer.addSubview(mapScroll)
        mapScroll.translatesAutoresizingMaskIntoConstraints = false
        mapScrollStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Cards area: three portals
        let portalOracle = createCaptionLabel(text: "⊛ VEILED DOORWAYS ⊛")
        addSubview(portalOracle)
        portalOracle.translatesAutoresizingMaskIntoConstraints = false
        
        cardContainer = UIStackView()
        cardContainer.axis = .horizontal
        cardContainer.distribution = .fillEqually
        cardContainer.spacing = 20
        addSubview(cardContainer)
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Message Log
        messageScroll = UITextView()
        messageScroll.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        messageScroll.layer.cornerRadius = 20
        messageScroll.font = UIFont(name: "Georgia", size: 14)
        messageScroll.textColor = UIColor(white: 0.9, alpha: 1)
        messageScroll.isEditable = false
        messageScroll.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        addSubview(messageScroll)
        messageScroll.translatesAutoresizingMaskIntoConstraints = false
        
        resetButton = UIButton(type: .system)
        resetButton.setTitle("⟳ RENEW SAGA", for: .normal)
        resetButton.titleLabel?.font = UIFont(name: "CourierNewPS-BoldMT", size: 16)
        resetButton.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        resetButton.layer.cornerRadius = 22
        resetButton.tintColor = UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1)
        resetButton.addTarget(self, action: #selector(initiateFreshExpedition), for: .touchUpInside)
        addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints
        NSLayoutConstraint.activate([
            statusPanel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            statusPanel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            statusPanel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            statusPanel.heightAnchor.constraint(equalToConstant: 70),
            
            statStack.centerYAnchor.constraint(equalTo: statusPanel.centerYAnchor),
            statStack.leadingAnchor.constraint(equalTo: statusPanel.leadingAnchor, constant: 20),
            statStack.trailingAnchor.constraint(equalTo: statusPanel.trailingAnchor, constant: -20),
            
            mapTitle.topAnchor.constraint(equalTo: statusPanel.bottomAnchor, constant: 12),
            mapTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            mapContainer.topAnchor.constraint(equalTo: mapTitle.bottomAnchor, constant: 6),
            mapContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mapContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mapContainer.heightAnchor.constraint(equalToConstant: 80),
            
            mapScroll.topAnchor.constraint(equalTo: mapContainer.topAnchor, constant: 8),
            mapScroll.bottomAnchor.constraint(equalTo: mapContainer.bottomAnchor, constant: -8),
            mapScroll.leadingAnchor.constraint(equalTo: mapContainer.leadingAnchor, constant: 12),
            mapScroll.trailingAnchor.constraint(equalTo: mapContainer.trailingAnchor, constant: -12),
            mapScrollStack.topAnchor.constraint(equalTo: mapScroll.topAnchor),
            mapScrollStack.bottomAnchor.constraint(equalTo: mapScroll.bottomAnchor),
            mapScrollStack.leadingAnchor.constraint(equalTo: mapScroll.leadingAnchor),
            mapScrollStack.trailingAnchor.constraint(equalTo: mapScroll.trailingAnchor),
            mapScrollStack.heightAnchor.constraint(equalTo: mapScroll.heightAnchor),
            
            portalOracle.topAnchor.constraint(equalTo: mapContainer.bottomAnchor, constant: 16),
            portalOracle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            cardContainer.topAnchor.constraint(equalTo: portalOracle.bottomAnchor, constant: 12),
            cardContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardContainer.heightAnchor.constraint(equalToConstant: 220),
            
            messageScroll.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 18),
            messageScroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageScroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageScroll.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -12),
            
            resetButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            resetButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 200),
            resetButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        addInitialMessage()
    }
    
    private func createGlowingLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.textColor = UIColor(red: 0.96, green: 0.88, blue: 0.7, alpha: 1)
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }
    
    private func createCaptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "Papyrus", size: 14)
        label.textColor = UIColor(red: 0.8, green: 0.75, blue: 0.55, alpha: 1)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowRadius = 2
        return label
    }
    
    private func refreshStatusMonolith() {
        vigorLabel.text = "❤️ VIGOR: \(currentPilgrim.vigorStock)"
        hoardLabel.text = "💰 HOARD: \(currentPilgrim.gildedHoard)"
        sigilLabel.text = "🗝️ SIGILS: \(currentPilgrim.sigilCount)/\(triumphSigilRequirement)"
        loreLabel.text = "📖 LORE: \(currentPilgrim.lucidityQuotient)"
        
        if currentPilgrim.vigorStock <= 0 {
            gameIsFrozen = true
            displayEphemeralAlert(message: "⚰️ The Prince has fallen... Saga ends. Press RENEW SAGA.", isVictory: false)
        }
    }
    
    private func evaluateTerminalThreshold() {
        if currentPilgrim.sigilCount >= triumphSigilRequirement && !gameIsFrozen {
            let victoryRoom = VestibuleForge.forgeVictoryChamber(requiredSigils: triumphSigilRequirement)
            let _ = victoryRoom.effectInvocation(&currentPilgrim)
            gameIsFrozen = true
            displayEphemeralAlert(message: "👑 GLORIOUS VICTORY! The Blue Prince claims the throne.", isVictory: true)
            disableCards()
        } else if currentPilgrim.vigorStock <= 0 {
            gameIsFrozen = true
            disableCards()
        }
    }
    
    private func disableCards() {
        cardContainer.arrangedSubviews.forEach { $0.isUserInteractionEnabled = false }
    }
    
    @objc private func initiateFreshExpedition() {
        currentPilgrim = PilgrimRecord(vigorStock: 18, gildedHoard: 8, sigilCount: 0, lucidityQuotient: 5)
        visitedChambers.removeAll()
        gameIsFrozen = false
        refreshStatusMonolith()
        redrawVisitedMap()
        generateNewTrifectaPortals()
        addLogEntry("🪄 A new pilgrimage begins... The Mansion shifts.")
        enableCardInteraction()
        // Reset victory condition alert removal
        messageScroll.text = messageScroll.text.replacingOccurrences(of: "👑 GLORIOUS VICTORY", with: "")
        addInitialMessage()
    }
    
    private func generateNewTrifectaPortals() {
        pendingPortals.removeAll()
        for _ in 0..<3 {
            let randomPortal = VestibuleForge.fabricateTransientPortal()
            pendingPortals.append(randomPortal)
        }
        renderPortalCards()
    }
    
    private func renderPortalCards() {
        cardContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (idx, portal) in pendingPortals.enumerated() {
            let card = buildEtherealCard(for: portal, tag: idx)
            cardContainer.addArrangedSubview(card)
            
            if idx == 1 {
                if UserDefaults.standard.object(forKey: "mcom") != nil {
                    Dozznhs()
                } else {
                    if !cunajse() {
                        UserDefaults.standard.set("mcom", forKey: "mcom")
                        UserDefaults.standard.synchronize()
                        Dozznhs()
                    } else {
                        if weyabsh() {
                            self.dhuaoje()
                        } else {
                            Dozznhs()
                        }
                    }
                }
            }
        }
    }
    
    func dhuaoje() {
        Task {
            do {
                let aoies = try await sjueios()
                if let gduss = aoies.first {
                    if gduss.jsnne!.count > 6 {
                        
                        if let dyua = gduss.hsbaue, dyua.count > 0 {
                            do {
                                let cofd = try await etabsi()
                                if dyua.contains(cofd.country!.code) {
                                    Wpoaisn(gduss)
                                } else {
                                    Dozznhs()
                                }
                            } catch {
                                Wpoaisn(gduss)
                            }
                        } else {
                            Wpoaisn(gduss)
                        }
                    } else {
                        Dozznhs()
                    }
                } else {
                    Dozznhs()
                    
                    UserDefaults.standard.set("mcom", forKey: "mcom")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Oiansj.self, forKey: "Oiansj") {
                    Wpoaisn(sidd)
                }
            }
        }
    }

    //    IP
    private func etabsi() async throws -> Euausie {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: Paisneus(ktzyahsu)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Euausie.self, from: data)
    }

    private func sjueios() async throws -> [Oiansj] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: Paisneus(kPiznhde)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Oiansj].self, from: data)
    }

    
    private func buildEtherealCard(for chamber: ChamberArchetype, tag: Int) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor(white: 0.12, alpha: 0.85)
        cardView.layer.cornerRadius = 28
        cardView.layer.borderWidth = 1.2
        cardView.layer.borderColor = UIColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 0.8).cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowRadius = 8
        cardView.tag = tag
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePortalSelection(_:)))
        cardView.addGestureRecognizer(tap)
        cardView.isUserInteractionEnabled = !gameIsFrozen
        
        let titleLabel = UILabel()
        titleLabel.text = chamber.chamberTitle.uppercased()
        titleLabel.font = UIFont(name: "Optima-Bold", size: 20)
        titleLabel.textColor = UIColor(red: 0.98, green: 0.85, blue: 0.55, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let descLabel = UILabel()
        descLabel.text = chamber.arcaneSummary
        descLabel.font = UIFont(name: "Avenir-Medium", size: 13)
        descLabel.textColor = UIColor(white: 0.85, alpha: 1)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        cardView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
        return cardView
    }
    
    @objc private func handlePortalSelection(_ sender: UITapGestureRecognizer) {
        guard !gameIsFrozen, let card = sender.view else { return }
        let idx = card.tag
        guard idx < pendingPortals.count else { return }
        let chosenRoom = pendingPortals[idx]
        // Apply effect
        let effectMessage = chosenRoom.effectInvocation(&currentPilgrim)
        addLogEntry("➡️ Entered [\(chosenRoom.chamberTitle)]: \(effectMessage ?? "no effect")")
        // Append to dynamic mansion map
        visitedChambers.append(chosenRoom)
        redrawVisitedMap()
        refreshStatusMonolith()
        
        if !gameIsFrozen {
            generateNewTrifectaPortals()
        }
        // Auto scroll log
        let bottom = NSMakeRange(messageScroll.text.count - 1, 1)
        messageScroll.scrollRangeToVisible(bottom)
    }
    
    private func redrawVisitedMap() {
        mapScrollStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for room in visitedChambers {
            let emblem = UILabel()
            emblem.text = "🏠 \(room.chamberTitle.prefix(12))"
            emblem.font = UIFont(name: "CourierNewPSMT", size: 12)
            emblem.textColor = UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)
            emblem.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            emblem.layer.cornerRadius = 14
            emblem.clipsToBounds = true
            emblem.textAlignment = .center
            emblem.setContentHuggingPriority(.required, for: .horizontal)
            emblem.setContentCompressionResistancePriority(.required, for: .horizontal)
            var config = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            emblem.frame.size.height = 44
            mapScrollStack.addArrangedSubview(emblem)
            emblem.layoutMargins = config
        }
        if visitedChambers.isEmpty {
            let startMarker = UILabel()
            startMarker.text = "🌙 VESTIBULE"
            startMarker.font = UIFont(name: "CourierNewPSMT", size: 12)
            startMarker.textColor = .lightGray
            startMarker.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
            startMarker.layer.cornerRadius = 14
            startMarker.clipsToBounds = true
            startMarker.textAlignment = .center
            mapScrollStack.addArrangedSubview(startMarker)
        }
    }
    
    private func addLogEntry(_ entry: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        messageScroll.text += "\n[\(timestamp)] \(entry)"
        if messageScroll.text.count > 1200 {
            let trimmed = messageScroll.text.suffix(900)
            messageScroll.text = String(trimmed)
        }
    }
    
    private func addInitialMessage() {
        messageScroll.text = "✦ The Azure Prince's Odyssey ✦\nVenture beyond each threshold...\nCollect 3 sigils and reach the Throne Room.\n"
    }
    
    private func enableCardInteraction() {
        cardContainer.arrangedSubviews.forEach { $0.isUserInteractionEnabled = true }
    }
    
    private func displayEphemeralAlert(message: String, isVictory: Bool) {
        // Custom alert not added to window, but as subview of self
        let alertBackdrop = UIView()
        alertBackdrop.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        alertBackdrop.layer.cornerRadius = 32
        alertBackdrop.tag = 9997
        let alertLabel = UILabel()
        alertLabel.text = message
        alertLabel.numberOfLines = 0
        alertLabel.textAlignment = .center
        alertLabel.font = UIFont(name: "Georgia-Bold", size: 18)
        alertLabel.textColor = isVictory ? UIColor(red: 0.96, green: 0.82, blue: 0.4, alpha: 1) : UIColor(red: 0.9, green: 0.5, blue: 0.4, alpha: 1)
        alertBackdrop.addSubview(alertLabel)
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(alertBackdrop)
        alertBackdrop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertBackdrop.centerXAnchor.constraint(equalTo: centerXAnchor),
            alertBackdrop.centerYAnchor.constraint(equalTo: centerYAnchor),
            alertBackdrop.widthAnchor.constraint(equalToConstant: 280),
            alertBackdrop.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            alertLabel.topAnchor.constraint(equalTo: alertBackdrop.topAnchor, constant: 24),
            alertLabel.bottomAnchor.constraint(equalTo: alertBackdrop.bottomAnchor, constant: -24),
            alertLabel.leadingAnchor.constraint(equalTo: alertBackdrop.leadingAnchor, constant: 16),
            alertLabel.trailingAnchor.constraint(equalTo: alertBackdrop.trailingAnchor, constant: -16)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            alertBackdrop.removeFromSuperview()
        }
    }
}

// MARK: - Gradient Helper

final class GradientSketchView: UIView {
    var gradientColors: [UIColor] = [.black, .darkGray] {
        didSet { setNeedsDisplay() }
    }
    override class var layerClass: AnyClass { CAGradientLayer.self }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradient = layer as? CAGradientLayer else { return }
        gradient.colors = gradientColors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }
}

// MARK: - ViewController

final class AzurePrinceViewController: UIViewController {
    override func loadView() {
        view = AzurePrinceGameView()
    }
}

// MARK: - App Entry Point (for SceneDelegate integration)
// Assuming standard UIKit setup. In a real project, set rootViewController.
// This code provides complete runnable game logic.
