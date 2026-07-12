import Foundation

/// A card from the pre-built catalog. This is the "database" of all known cards.
/// Users browse this catalog and add cards to "My Cards."
struct CatalogCard: Identifiable, Hashable, Codable {
    let cardID: String
    let name: String
    let issuer: String
    let colorHex: String
    let network: String
    let annualFee: Int        // in dollars, 0 if none
    let multipliers: [CardMultiplier]
    let hasRotatingCategories: Bool
    let description: String
    var id: String { cardID }
}