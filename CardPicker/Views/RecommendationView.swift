import SwiftUI
import SwiftData

/// Recommendation screen: shows ranked cards for a given category.
/// P0 (best card) is highlighted; P1 alternatives listed below with reasoning.
struct RecommendationView: View {
    let category: TransactionCategory

    @Environment(\.modelContext) private var modelContext
    @Query private var userCards: [CreditCard]
    @State private var rotatingCategories: [RotatingCategory] = []

    var body: some View {
        let recs = RecommendationEngine.recommendations(
            for: category,
            userCards: userCards,
            rotatingCategories: rotatingCategories
        )

        ScrollView {
            VStack(spacing: 20) {
                // Category header
                HStack(spacing: 12) {
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundStyle(Color(hex: category.sfColor))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color(hex: category.sfColor).opacity(0.15)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Best card to use")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                if recs.isEmpty {
                    Text("Add cards to see recommendations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 60)
                } else {
                    // P0 — Best card
                    if let p0 = recs.first {
                        P0CardView(recommendation: p0)
                            .padding(.horizontal)

                        Text("Alternatives")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // P1+ alternatives
                        ForEach(recs.dropFirst(), id: \.card.cardID) { rec in
                            P1CardView(recommendation: rec, p0: p0)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color.black.opacity(0.95).ignoresSafeArea())
        .navigationTitle("Recommendation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .task {
            rotatingCategories = CardCatalogLoader.loadRotatingCategories()
        }
    }
}

/// P0 — the best card. Large, prominent display.
struct P0CardView: View {
    let recommendation: RecommendationEngine.Recommendation

    var body: some View {
        let card = recommendation.card
        let accentColor = Color(hex: card.colorHex)

        VStack(spacing: 0) {
            // Card-like visual
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(card.issuer)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text("BEST")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.white))
                    }

                    Spacer()

                    Text(card.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack {
                        Text(RecommendationEngine.formatMultiplier(recommendation.multiplier))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("on \(recommendation.card.issuer)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        if recommendation.isRotatingBonus {
                            Label("5x Bonus", systemImage: "sparkles")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                .padding(16)
            }

            // Reasoning
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(accentColor)
                    Text("Why this card")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(recommendation.note)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

/// P1+ — alternative cards. Smaller, scannable.
struct P1CardView: View {
    let recommendation: RecommendationEngine.Recommendation
    let p0: RecommendationEngine.Recommendation

    var body: some View {
        let card = recommendation.card
        let accentColor = Color(hex: card.colorHex)

        HStack(spacing: 14) {
            // Mini card swatch
            RoundedRectangle(cornerRadius: 8)
                .fill(accentColor)
                .frame(width: 48, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)

                Text(recommendation.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if recommendation.multiplier != p0.multiplier {
                    Text(RecommendationEngine.reasoningText(p0: p0, p1: recommendation))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(RecommendationEngine.formatMultiplier(recommendation.multiplier))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)
                Text("P\(recommendation.rank)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
        )
    }
}