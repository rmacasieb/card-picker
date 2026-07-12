import Foundation
import SwiftData

/// Represents a transaction category (Dining, Groceries, Gas, etc.)
/// Uses SF Symbols for icons. This is a value type — not persisted independently;
/// it's embedded in card multiplier relationships and used as a filter key.
struct TransactionCategory: Identifiable, Hashable, Codable {
    let id: String        // slug like "dining", "groceries"
    let name: String      // "Dining"
    let icon: String      // SF Symbol name e.g. "fork.knife"
    let sfColor: String   // hex color for the icon accent

    init(id: String, name: String, icon: String, sfColor: String = "0x34C759") {
        self.id = id
        self.name = name
        self.icon = icon
        self.sfColor = sfColor
    }
}