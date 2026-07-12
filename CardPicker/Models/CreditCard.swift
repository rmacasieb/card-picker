import Foundation
import SwiftData

/// A credit card the user has added to "My Cards."
/// Persisted via SwiftData. Each card references a catalog card's multiplier data
/// but stores its own copy so users can override or the catalog can update independently.
@Model
final class CreditCard {
    /// UUID as string for stable identity
    @Attribute(.unique) var cardID: String

    /// Display name e.g. "Chase Sapphire Reserve"
    var name: String

    /// Issuer e.g. "Chase"
    var issuer: String

    /// Hex color string for card accent (e.g. "1E3A5F" for Chase blue)
    var colorHex: String

    /// Network e.g. "Visa", "Mastercard", "Amex"
    var network: String

    /// JSON-encoded array of (category ID → multiplier) entries
    var multipliersJSON: String

    /// Whether this card has rotating quarterly categories
    var hasRotatingCategories: Bool

    /// Optional note for the user
    var notes: String

    /// Date added
    var dateAdded: Date

    init(
        cardID: String,
        name: String,
        issuer: String,
        colorHex: String,
        network: String,
        multipliersJSON: String,
        hasRotatingCategories: Bool = false,
        notes: String = "",
        dateAdded: Date = .now
    ) {
        self.cardID = cardID
        self.name = name
        self.issuer = issuer
        self.colorHex = colorHex
        self.network = network
        self.multipliersJSON = multipliersJSON
        self.hasRotatingCategories = hasRotatingCategories
        self.notes = notes
        self.dateAdded = dateAdded
    }

    /// Parsed multipliers — list of (categoryId, multiplier, note)
    var multipliers: [CardMultiplier] {
        guard let data = multipliersJSON.data(using: .utf8),
              let arr = try? JSONDecoder().decode([CardMultiplier].self, from: data)
        else { return [] }
        return arr
    }
}