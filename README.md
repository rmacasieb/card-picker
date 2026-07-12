# Card Picker

> Which credit card should I use for this purchase?

Card Picker is an iOS app that tells you which credit card to use for a given transaction category. Open the app → pick what you're about to buy → see which of your cards to use and why.

## Screens

1. **Home (Pick)** — Grid of transaction categories (Dining, Groceries, Gas, Travel, Streaming, Online Shopping, etc.). Tap one to get a recommendation.
2. **Recommendation** — Shows your best card (P0) with reasoning (e.g., "Amex Gold — 4x on dining"). Below it, P1 alternatives with comparison reasoning.
3. **My Cards** — List of cards you've added. Add/remove cards. Tap a card for details.
4. **Card Detail** — See a card's categories, multipliers, and metadata.
5. **Catalog** — Browse ~15 pre-built credit cards and add them to your wallet.

## Features

- **Pre-built card catalog** with 15 popular credit cards and their real multipliers
- **14 transaction categories** with SF Symbol icons and accent colors
- **Recommendation engine** that ranks your cards by best multiplier for a category
- **Rotating 5x categories** for Chase Freedom Flex and Discover It, loaded from embedded JSON
- **Quarterly awareness** — shows active rotating bonuses with "last updated" date
- **SwiftData persistence** — your cards persist across app launches
- **Dark mode native** — designed for dark mode with card-color accents
- **No accounts, no sync, no notifications** — fully local

## Tech Stack

- SwiftUI (iOS 17+)
- SwiftData for persistence
- NavigationStack for navigation
- `@Model` macro for SwiftData models
- `@Query` for fetching cards
- `@Observable` patterns
- SF Symbols for all icons

## Setup

### Requirements

- Mac with Xcode 15.0+ (M1 Mac or any Apple Silicon Mac)
- iOS 17.0+ simulator or device

### Instructions

1. Clone this repo:
   ```bash
   git clone https://github.com/rmacasieb/card-picker.git
   cd card-picker
   ```

2. Open in Xcode:
   ```bash
   open CardPicker.xcodeproj
   ```

3. Select a simulator (iPhone 15 Pro or any iOS 17+ simulator)

4. Press `Cmd+R` to build and run

That's it. No dependencies, no CocoaPods, no SPM packages — everything is self-contained.

## Project Structure

```
CardPicker/
├── CardPickerApp.swift          # App entry point
├── Info.plist                    # App configuration
├── CardPicker.entitlements      # App entitlements
├── Models/
│   ├── TransactionCategory.swift  # Category value type
│   ├── CreditCard.swift           # SwiftData @Model
│   ├── CardMultiplier.swift       # Multiplier value type
│   ├── RotatingCategory.swift     # Quarterly bonus struct
│   ├── CatalogCard.swift           # Catalog card struct
│   └── Color+Hex.swift             # Color hex extension
├── Views/
│   ├── RootView.swift             # TabView root
│   ├── HomeView.swift              # Category grid
│   ├── RecommendationView.swift    # P0/P1 recommendations
│   ├── MyCardsView.swift           # User's cards list
│   ├── CardDetailView.swift        # Card detail screen
│   └── CardCatalogView.swift       # Browse & add cards
├── ViewModels/
│   └── RecommendationEngine.swift  # Ranking logic
├── Data/
│   ├── CategoryCatalog.swift      # 12 pre-built categories
│   └── CardCatalogLoader.swift    # JSON loader
└── Resources/
    ├── CardCatalog.json           # 15 cards with multipliers
    └── RotatingCategories.json     # Quarterly rotating bonuses
```

## Pre-built Cards

| Card | Issuer | Annual Fee | Key Multipliers |
|------|--------|-----------|-----------------|
| Chase Sapphire Reserve | Chase | $550 | 10x travel portal, 3x dining/travel/streaming/transit |
| Chase Sapphire Preferred | Chase | $95 | 5x travel portal, 3x dining/streaming, 2x travel |
| Chase Freedom Flex | Chase | $0 | 5x rotating, 3x dining/drugstores |
| Chase Freedom Unlimited | Chase | $0 | 1.5x everything, 3x dining/drugstores |
| Amex Platinum | Amex | $695 | 5x flights/hotels |
| Amex Gold | Amex | $325 | 4x dining, 4x groceries |
| Amex Blue Cash Preferred | Amex | $95 | 6% groceries/streaming, 3% gas/transit |
| Amex Blue Cash Everyday | Amex | $0 | 3% groceries/online, 2% gas |
| Capital One Venture X | Capital One | $395 | 10x travel portal, 2x everything |
| Capital One SavorOne | Capital One | $0 | 3x dining/groceries/streaming, 8x Vivid Seats |
| Citi Double Cash | Citi | $0 | 2% on everything |
| Discover It | Discover | $0 | 5x rotating, 1x other |
| BoA Customized Cash | BoA | $0 | 3% chosen category, 1% other |
| Wells Fargo Autograph | Wells Fargo | $0 | 3x dining/travel/transit/streaming/phone/gas |
| US Bank Altitude Go | US Bank | $0 | 4x dining, 2x groceries/gas/streaming/transit |

## How It Works

1. **Add cards**: Go to the Catalog tab, tap the + button on cards you own
2. **Get recommendations**: Go to the Pick tab, tap a category (e.g., Dining)
3. **See your best card**: P0 card highlighted with multiplier and reasoning
4. **Compare alternatives**: P1 cards listed with comparison text
5. **Rotating bonuses**: Active quarterly 5x categories shown on Home screen

## Updating Rotating Categories

The `RotatingCategories.json` file in `CardPicker/Resources/` contains quarterly bonus data. To update:

1. Edit the JSON file with new quarterly categories
2. Update the `lastUpdated` timestamp
3. Rebuild the app

In a future version, this can be moved to a remote URL for over-the-air updates.

## License

Personal project for Romy Macasieb. No license — for personal use only.

## Notes

- Multiplier data is based on publicly available card terms as of July 2026. Always verify with your card issuer.
- This app is for informational purposes only and does not constitute financial advice.