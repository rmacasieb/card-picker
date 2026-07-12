import SwiftUI
import SwiftData

/// Card catalog: browse all pre-built cards and add them to "My Cards."
struct CardCatalogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userCards: [CreditCard]

    @State private var catalog: [CatalogCard] = []
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()

                List {
                    ForEach(filteredCatalog, id: \.cardID) { card in
                        CatalogCardRow(
                            catalogCard: card,
                            isAdded: userCards.contains { $0.cardID == card.cardID },
                            onAdd: { addCard(card) },
                            onRemove: { removeCard(card) }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search cards")
        }
        .task {
            catalog = CardCatalogLoader.loadCards()
        }
    }

    private var filteredCatalog: [CatalogCard] {
        if searchText.isEmpty { return catalog }
        return catalog.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.issuer.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func addCard(_ catalogCard: CatalogCard) {
        let multipliersJSON = (try? JSONEncoder().encode(catalogCard.multipliers))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        let card = CreditCard(
            cardID: catalogCard.cardID,
            name: catalogCard.name,
            issuer: catalogCard.issuer,
            colorHex: catalogCard.colorHex,
            network: catalogCard.network,
            multipliersJSON: multipliersJSON,
            hasRotatingCategories: catalogCard.hasRotatingCategories,
            notes: catalogCard.description,
            dateAdded: .now
        )
        modelContext.insert(card)
        try? modelContext.save()
    }

    private func removeCard(_ catalogCard: CatalogCard) {
        if let card = userCards.first(where: { $0.cardID == catalogCard.cardID }) {
            modelContext.delete(card)
            try? modelContext.save()
        }
    }
}

/// A single row in the catalog list.
struct CatalogCardRow: View {
    let catalogCard: CatalogCard
    let isAdded: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        let accentColor = Color(hex: catalogCard.colorHex)

        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(accentColor)
                .frame(width: 52, height: 38)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(catalogCard.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)

                HStack(spacing: 4) {
                    Text(catalogCard.issuer)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(catalogCard.annualFee)/yr")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if catalogCard.hasRotatingCategories {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }

                // Top multipliers preview
                HStack(spacing: 6) {
                    ForEach(topMultipliers, id: \.categoryId) { mult in
                        if let cat = CategoryCatalog.find(mult.categoryId) {
                            HStack(spacing: 2) {
                                Image(systemName: cat.icon)
                                    .font(.system(size: 9))
                                Text(RecommendationEngine.formatMultiplier(mult.multiplier))
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(Color(hex: cat.sfColor))
                        }
                    }
                }
                .padding(.top, 2)
            }

            Spacer()

            Button(action: isAdded ? onRemove : onAdd) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isAdded ? .green : accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
    }

    /// Top 4 highest multipliers for preview.
    private var topMultipliers: [CardMultiplier] {
        catalogCard.multipliers
            .filter { $0.categoryId != "other" }
            .sorted { $0.multiplier > $1.multiplier }
            .prefix(4)
            .map { $0 }
    }
}