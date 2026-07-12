import SwiftUI
import SwiftData

/// Home screen: a clean grid of category tiles. Tap one to see the best card.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.dateAdded, order: .reverse) private var userCards: [CreditCard]
    @State private var rotatingCategories: [RotatingCategory] = []
    @State private var selectedCategory: TransactionCategory?

    /// Two-column grid for categories.
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Tagline
                        Text("Which card should I use?")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        Text("Tap a category to see your best card.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        // Category grid — the hero
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(CategoryCatalog.categories) { category in
                                CategoryTile(category: category)
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Card Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
        }
        .task {
            rotatingCategories = CardCatalogLoader.loadRotatingCategories()
        }
        .sheet(item: $selectedCategory) { category in
            CategoryRecommendationSheet(
                category: category,
                userCards: userCards,
                rotatingCategories: rotatingCategories
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Category Tile

/// A large tappable category tile for the hero grid.
struct CategoryTile: View {
    let category: TransactionCategory

    private var accentColor: Color { Color(hex: category.sfColor) }

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: category.icon)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(accentColor)
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .overlay(
                            Circle()
                                .stroke(accentColor.opacity(0.25), lineWidth: 1)
                        )
                )

            Text(category.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Category Recommendation Sheet

/// Sheet that appears when tapping a category tile.
/// Shows the best card for the tapped category, with alternatives below.
struct CategoryRecommendationSheet: View {
    let category: TransactionCategory
    let userCards: [CreditCard]
    let rotatingCategories: [RotatingCategory]
    @Environment(\.dismiss) private var dismiss

    private var recs: [RecommendationEngine.Recommendation] {
        RecommendationEngine.recommendations(
            for: category,
            userCards: userCards,
            rotatingCategories: rotatingCategories
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()

                if userCards.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.3))

                        Text("No cards in your wallet yet")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text("Add cards from the Catalog tab to get recommendations.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else if recs.isEmpty {
                    Text("No recommendations available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Category header
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .font(.title2)
                                    .foregroundStyle(Color(hex: category.sfColor))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle().fill(Color(hex: category.sfColor).opacity(0.15))
                                    )

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

                            // P0 — Best card
                            if let p0 = recs.first {
                                P0CardView(recommendation: p0)
                                    .padding(.horizontal)

                                // Alternatives
                                if recs.count > 1 {
                                    Text("Alternatives")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)

                                    ForEach(recs.dropFirst(), id: \.card.cardID) { rec in
                                        P1CardView(recommendation: rec, p0: p0)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - Empty State

/// Empty state view (kept for compatibility).
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))

            Text("No cards yet")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Text("Add cards to your wallet to get recommendations on which card to use for each purchase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                Text("Go to the Catalog tab to add cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
    }
}