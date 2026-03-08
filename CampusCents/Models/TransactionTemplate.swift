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
        .init(title: "Library cafe snack", amount: 7.25, category: .personal),
        .init(title: "Groceries run", amount: 35.00, category: .groceries),
        .init(title: "Trader Joe's haul", amount: 48.75, category: .groceries),
        .init(title: "Gas", amount: 45.00, category: .transportation),
        .init(title: "Campus parking", amount: 12.00, category: .transportation),
        .init(title: "Uber home", amount: 16.50, category: .transportation),
        .init(title: "Takeout", amount: 18.00, category: .mealPlan),
        .init(title: "Dining hall reload", amount: 25.00, category: .mealPlan),
        .init(title: "Laundry", amount: 8.00, category: .utilities),
        .init(title: "Phone bill", amount: 45.00, category: .utilities),
        .init(title: "Streaming", amount: 14.99, category: .subscriptions),
        .init(title: "Rent payment", amount: 750.00, category: .rent),
        .init(title: "Textbook", amount: 62.00, category: .personal),
    ]
}
