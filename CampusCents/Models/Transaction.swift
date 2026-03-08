import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: BudgetCategory.Kind

    static let sample: [Transaction] = [
        .init(id: UUID(), title: "Groceries - Campus Mart", amount: 42.18, date: .now.addingTimeInterval(-86400), category: .groceries),
        .init(id: UUID(), title: "Spotify Student", amount: 5.99, date: .now.addingTimeInterval(-172800), category: .subscriptions),
        .init(id: UUID(), title: "Gas - Shell", amount: 28.50, date: .now.addingTimeInterval(-259200), category: .transportation),
        .init(id: UUID(), title: "Utilities - Power", amount: 54.20, date: .now.addingTimeInterval(-432000), category: .utilities)
    ]
}
