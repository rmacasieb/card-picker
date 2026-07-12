import Foundation

/// Quarterly rotating bonus categories for cards like Chase Freedom Flex / Discover It.
/// Loaded from embedded JSON. Each entry specifies the card, quarter, year, categories, and multiplier.
struct RotatingCategory: Identifiable, Hashable, Codable {
    let id: String
    let cardID: String       // matches CatalogCard.cardID
    let year: Int
    let quarter: Int          // 1-4
    let categoryIds: [String] // e.g. ["groceries", "gas"]
    let multiplier: Double    // e.g. 5.0
    let note: String          // e.g. "5x on Groceries and Gas (up to $1,500/quarter)"

    /// Check if this rotation is active for the current quarter
    var isCurrentQuarter: Bool {
        let month = Calendar.current.component(.month, from: .now)
        let currentQuarter = (month - 1) / 3 + 1
        let currentYear = Calendar.current.component(.year, from: .now)
        return year == currentYear && quarter == currentQuarter
    }
}