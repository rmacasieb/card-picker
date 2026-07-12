import SwiftUI
import SwiftData

/// Home screen: top recommended card as a hero, category chips, and your wallet below.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.dateAdded, order: .reverse) private var userCards: [CreditCard]
    @State private var rotatingCategories: [RotatingCategory] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()

                if userCards.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Hero: top recommended card
                            if let pick = RecommendationEngine.topPick(
                                userCards: userCards,
                                rotatingCategories: rotatingCategories
                            ) {
                                HeroRecommendationCard(pick: pick)
                                    .padding(.horizontal)
                            }

                            // Rotating categories banner
                            if !currentRotations.isEmpty {
                                rotatingBanner
                            }

                            // Category chips
                            categoryChipsSection

                            // Your wallet
                            walletSection
                        }
                        .padding(.top)
                        .padding(.bottom, 24)
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

    /// Horizontally scrollable category chips that navigate to RecommendationView.
    private var categoryChipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse by Category")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CategoryCatalog.categories) { category in
                        NavigationLink(destination: RecommendationView(category: category)) {
                            CategoryChip(category: category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    /// "Your Wallet" section: compact list of saved cards, tap to see details.
    private var walletSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Wallet")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(userCards, id: \.cardID) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        WalletCardRow(card: card)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Hero card: the top recommended card with inline "why" and chevron to see all.
struct HeroRecommendationCard: View {
    let pick: RecommendationEngine.TopPick

    var body: some View {
        let card = pick.card
        let accentColor = Color(hex: card.colorHex)

        VStack(spacing: 0) {
            // Card visual
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(card.issuer)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        if pick.isRotatingBonus {
                            Label("5x Bonus", systemImage: "sparkles")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.yellow)
                        }
                    }

                    Spacer()

                    Text(card.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(RecommendationEngine.formatMultiplier(pick.multiplier))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("on \(pick.category.name)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))
                        Spacer()
                        Image(systemName: pick.category.icon)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(18)
            }

            // "Why" + chevron to detail
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .font(.subheadline)
                        .foregroundStyle(accentColor)

                    Text(pick.shortWhy)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(3)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 12)

                Divider()
                    .background(.white.opacity(0.08))

                NavigationLink(destination: RecommendationView(category: pick.category)) {
                    HStack {
                        Text("See all cards for \(pick.category.name)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(accentColor)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(accentColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .background(Color.white.opacity(0.04))
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.08))
        )
    }
}

/// A horizontally scrollable category chip.
struct CategoryChip: View {
    let category: TransactionCategory

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.body)
                .foregroundStyle(Color(hex: category.sfColor))
            Text(category.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: category.sfColor).opacity(0.25), lineWidth: 1)
                )
        )
    }
}

/// Compact wallet row for the home screen.
struct WalletCardRow: View {
    let card: CreditCard

    var body: some View {
        let accentColor = Color(hex: card.colorHex)

        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(accentColor)
                .frame(width: 44, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                Text(card.issuer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if card.hasRotatingCategories {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
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
