import Foundation

struct TransactionTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var category: BudgetCategory.Kind

    init(id: UUID = UUID(), title: String, amount: Double, category: BudgetCategory.Kind) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
    }

    static let defaults: [TransactionTemplate] = [
        .init(title: "Coffee", amount: 5.50, category: .personal),
        .init(title: "Groceries run", amount: 35.00, category: .groceries),
        .init(title: "Gas", amount: 45.00, category: .transportation),
        .init(title: "Takeout", amount: 18.00, category: .mealPlan),
        .init(title: "Streaming", amount: 14.99, category: .subscriptions),
    ]
}
