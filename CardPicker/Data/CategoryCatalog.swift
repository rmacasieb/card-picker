import Foundation

/// Pre-built transaction categories with SF Symbol icons.
enum CategoryCatalog {
    static let categories: [TransactionCategory] = [
        TransactionCategory(id: "dining",           name: "Dining",          icon: "fork.knife",           sfColor: "FF6B6B"),
        TransactionCategory(id: "groceries",         name: "Groceries",        icon: "cart.fill",            sfColor: "34C759"),
        TransactionCategory(id: "gas",              name: "Gas",              icon: "fuelpump.fill",        sfColor: "FF9500"),
        TransactionCategory(id: "travel",           name: "Travel",           icon: "airplane",             sfColor: "0A84FF"),
        TransactionCategory(id: "streaming",        name: "Streaming",        icon: "play.tv.fill",         sfColor: "BF5AF2"),
        TransactionCategory(id: "online_shopping", name: "Online Shopping",  icon: "bag.fill",             sfColor: "FF375F"),
        TransactionCategory(id: "drugstores",       name: "Drugstores",       icon: "cross.case.fill",      sfColor: "FFD60A"),
        TransactionCategory(id: "transit",         name: "Transit",          icon: "tram.fill",            sfColor: "64D2FF"),
        TransactionCategory(id: "entertainment",   name: "Entertainment",    icon: "theatermasks.fill",    sfColor: "FF2D55"),
        TransactionCategory(id: "utilities",       name: "Utilities",        icon: "bolt.fill",            sfColor: "FFCC00"),
        TransactionCategory(id: "phone",           name: "Phone",            icon: "phone.fill",          sfColor: "30D158"),
        TransactionCategory(id: "other",           name: "Other",            icon: "creditcard.fill",      sfColor: "8E8E93"),
    ]

    static func find(_ id: String) -> TransactionCategory? {
        categories.first { $0.id == id }
    }
}