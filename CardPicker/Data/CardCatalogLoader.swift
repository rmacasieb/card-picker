import Foundation

/// Loads the pre-built card catalog from embedded JSON and provides
/// helpers to look up cards and quarterly rotating categories.
enum CardCatalogLoader {
    /// Load all catalog cards from the bundled JSON file.
    static func loadCards() -> [CatalogCard] {
        guard let url = Bundle.main.url(forResource: "CardCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cards = try? JSONDecoder().decode([CatalogCard].self, from: data)
        else {
            // If JSON fails, return the hardcoded fallback
            return fallbackCards
        }
        return cards
    }

    /// Load rotating bonus categories from the bundled JSON.
    /// The JSON has a wrapper: { "lastUpdated": "...", "rotations": [...] }
    static func loadRotatingCategories() -> [RotatingCategory] {
        guard let url = Bundle.main.url(forResource: "RotatingCategories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rotationsArray = json["rotations"]
        else { return [] }

        let rotationsData = try? JSONSerialization.data(withJSONObject: rotationsArray)
        guard let rotationsData,
              let rotations = try? JSONDecoder().decode([RotatingCategory].self, from: rotationsData)
        else { return [] }
        return rotations
    }

    /// The "last updated" date from the rotating categories JSON metadata.
    static var rotatingDataLastUpdated: Date? {
        guard let url = Bundle.main.url(forResource: "RotatingCategories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let lastUpdated = json["lastUpdated"] as? String
        else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: lastUpdated)
    }

    /// Fallback hardcoded cards in case JSON is missing (shouldn't happen in production).
    static let fallbackCards: [CatalogCard] = [
        CatalogCard(
            cardID: "chase-sapphire-reserve",
            name: "Chase Sapphire Reserve",
            issuer: "Chase",
            colorHex: "1A3A5C",
            network: "Visa Infinite",
            annualFee: 550,
            multipliers: [
                CardMultiplier(categoryId: "dining", multiplier: 3.0, note: "3x points on dining"),
                CardMultiplier(categoryId: "travel", multiplier: 3.0, note: "10x on Chase Travel portal, 3x on other travel"),
                CardMultiplier(categoryId: "streaming", multiplier: 3.0, note: "3x on select streaming"),
                CardMultiplier(categoryId: "online_shopping", multiplier: 3.0, note: "3x on select online grocery (through Mar 2025)"),
                CardMultiplier(categoryId: "transit", multiplier: 3.0, note: "3x on transit"),
                CardMultiplier(categoryId: "drugstores", multiplier: 3.0, note: "3x on select drugstores"),
                CardMultiplier(categoryId: "other", multiplier: 1.0, note: "1x on everything else"),
            ],
            hasRotatingCategories: false,
            description: "Premium travel card with 3x on dining, travel, streaming, and transit."
        ),
    ]
}