import SwiftUI
import SwiftData

/// Card detail screen: shows a card's categories, multipliers, and metadata.
struct CardDetailView: View {
    let card: CreditCard

    var body: some View {
        let accentColor = Color(hex: card.colorHex)

        ScrollView {
            VStack(spacing: 20) {
                // Card visual
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(card.issuer)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))
                            Spacer()
                            Text(card.network)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        Text(card.name)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)

                        if card.hasRotatingCategories {
                            Label("Rotating 5x Categories", systemImage: "arrow.triangle.2.circlepath")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.yellow)
                        }
                    }
                    .padding(18)
                }

                // Multipliers section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bonus Categories")
                        .font(.headline)
                        .foregroundStyle(.white)

                    ForEach(card.multipliers, id: \.categoryId) { mult in
                        if let cat = CategoryCatalog.find(mult.categoryId) {
                            HStack(spacing: 12) {
                                Image(systemName: cat.icon)
                                    .font(.body)
                                    .foregroundStyle(Color(hex: cat.sfColor))
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color(hex: cat.sfColor).opacity(0.15)))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cat.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.white)
                                    Text(mult.note)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Text(RecommendationEngine.formatMultiplier(mult.multiplier))
                                    .font(.headline.weight(.bold, design: .rounded))
                                    .foregroundStyle(accentColor)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                )

                // Notes
                if !card.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(card.notes)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.04))
                    )
                }
            }
            .padding()
        }
        .background(Color.black.opacity(0.95).ignoresSafeArea())
        .navigationTitle("Card Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
    }
}