import SwiftUI
import SwiftData

/// Root tab view with three tabs: Home (categories), My Cards, and Card Catalog.
struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Pick", systemImage: "creditcard.fill")
                }

            MyCardsView()
                .tabItem {
                    Label("My Cards", systemImage: "rectangle.stack.fill")
                }

            CardCatalogView()
                .tabItem {
                    Label("Catalog", systemImage: "square.grid.2x2.fill")
                }
        }
        .tint(.white)
    }
}