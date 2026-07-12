import SwiftUI
import SwiftData

/// Home screen: grid of transaction categories. Tap one to see recommendations.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userCards: [CreditCard]
    @State private var rotatingCategories: [RotatingCategory] = []

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()

                if userCards.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Rotating categories banner
                            if !currentRotations.isEmpty {
                                rotatingBanner
                            }

                            // Category grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(CategoryCatalog.categories) { category in
                                    NavigationLink(destination: RecommendationView(category: category)) {
                                        CategoryCard(category: category)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                    }
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
    }

    /// Rotating categories that are active right now.
    private var currentRotations: [RotatingCategory] {
        rotatingCategories.filter { $0.isCurrentQuarter }
    }

    /// Banner showing active rotating bonus categories.
    private var rotatingBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("Active 5x Rotating Categories")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.yellow)
                Spacer()
                if let lastUpdated = CardCatalogLoader.rotatingDataLastUpdated {
                    Text("Updated \(lastUpdated.formatted(.dateTime.month().day().year()))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(currentRotations) { rotation in
                if let card = userCards.first(where: { $0.cardID == rotation.cardID }) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: card.colorHex))
                            .frame(width: 10, height: 10)
                        Text("\(card.name): \(rotation.note)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.yellow.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

/// A single category tile in the grid.
struct CategoryCard: View {
    let category: TransactionCategory

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title)
                .foregroundStyle(Color(hex: category.sfColor))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color(hex: category.sfColor).opacity(0.15))
                )

            Text(category.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
        )
    }
}

/// Empty state when user hasn't added any cards yet.
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