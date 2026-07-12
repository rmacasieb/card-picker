import Foundation
import SwiftData

/// The recommendation engine: given a category and the user's cards,
/// ranks all cards by best multiplier for that category and generates reasoning text.
enum RecommendationEngine {

    /// A single recommendation result for one card.
    struct Recommendation: Identifiable {
        let card: CreditCard
        let multiplier: Double
        let note: String
        let isRotatingBonus: Bool
        let rank: Int      // 0 = P0, 1 = P1, etc.
        var id: String { card.cardID }
    }

    /// Generate ranked recommendations for a category from the user's cards.
    /// - Parameters:
    ///   - category: The transaction category
    ///   - userCards: Cards the user has added
    ///   - rotatingCategories: Rotating bonus data from JSON
    /// - Returns: Sorted array of recommendations (best first)
    static func recommendations(
        for category: TransactionCategory,
        userCards: [CreditCard],
        rotatingCategories: [RotatingCategory]
    ) -> [Recommendation] {
        var results: [Recommendation] = []

        for card in userCards {
            // First check rotating categories (5x bonus)
            let rotating = rotatingCategories.filter {
                $0.cardID == card.cardID && $0.isCurrentQuarter && $0.categoryIds.contains(category.id)
            }

            if let activeRotation = rotating.first {
                results.append(Recommendation(
                    card: card,
                    multiplier: activeRotation.multiplier,
                    note: activeRotation.note,
                    isRotatingBonus: true,
                    rank: 0
                ))
                continue
            }

            // Otherwise check static multipliers
            let staticMult = card.multipliers.first { $0.categoryId == category.id }
            let multiplier = staticMult?.multiplier ?? 1.0
            let note = staticMult?.note ?? "1x on everything else"

            results.append(Recommendation(
                card: card,
                multiplier: multiplier,
                note: note,
                isRotatingBonus: false,
                rank: 0
            ))
        }

        // Sort by multiplier descending
        let sorted = results.sorted { $0.multiplier > $1.multiplier }

        // Assign ranks
        return sorted.enumerated().map { index, rec in
            Recommendation(
                card: rec.card,
                multiplier: rec.multiplier,
                note: rec.note,
                isRotatingBonus: rec.isRotatingBonus,
                rank: index
            )
        }
    }

    /// Generate reasoning text comparing the P0 card to a P1 card.
    static func reasoningText(p0: Recommendation, p1: Recommendation) -> String {
        if p0.multiplier == p1.multiplier {
            return "Tie at \(formatMultiplier(p0.multiplier)) — use \(p0.card.name) for primary benefits (annual fee credits, insurance, etc.)"
        }
        let diff = p0.multiplier - p1.multiplier
        return "\(p0.card.name) gives \(formatMultiplier(p0.multiplier)) vs \(formatMultiplier(p1.multiplier)) on \(p1.card.issuer). " +
               "\(p0.isRotatingBonus ? "Quarterly 5x bonus active. " : "")" +
               "\(diff > 0 ? "+\(String(format: "%.1f", diff))x better" : "")"
    }

    /// Format multiplier for display: "3x" or "3.5x"
    static func formatMultiplier(_ m: Double) -> String {
        if m == m.rounded() {
            return "\(Int(m))x"
        }
        return "\(String(format: "%.1f", m))x"
    }
}