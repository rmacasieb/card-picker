import SwiftUI
import SwiftData

/// "My Cards" screen: list of cards the user has added, with add/remove.
struct MyCardsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.dateAdded, order: .reverse) private var userCards: [CreditCard]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()

                if userCards.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.3))

                        Text("Your wallet is empty")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        Text("Add cards from the catalog to start getting recommendations.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(userCards, id: \.cardID) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                CardRowView(card: card)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteCard)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }

    private func deleteCard(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(userCards[index])
        }
        try? modelContext.save()
    }
}

/// A single card row in the My Cards list.
struct CardRowView: View {
    let card: CreditCard

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: card.colorHex))
                .frame(width: 52, height: 38)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                HStack(spacing: 4) {
                    Text(card.issuer)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(card.network)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
        .padding(.vertical, 6)
    }
}