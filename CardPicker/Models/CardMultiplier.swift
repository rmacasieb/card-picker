import Foundation

/// A single multiplier entry: which category this card bonuses on and at what rate.
/// e.g. { categoryId: "dining", multiplier: 3.0, note: "3x points on dining" }
struct CardMultiplier: Identifiable, Hashable, Codable {
    let categoryId: String
    let multiplier: Double
    let note: String

    var id: String { categoryId }

    init(categoryId: String, multiplier: Double, note: String = "") {
        self.categoryId = categoryId
        self.multiplier = multiplier
        self.note = note
    }
}