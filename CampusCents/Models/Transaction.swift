import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: BudgetCategory.Kind

    static let sample: [Transaction] = [
        .init(id: UUID(), title: "Rent - March", amount: 750.00, date: .now.addingTimeInterval(-21600), category: .rent),
        .init(id: UUID(), title: "Coffee - Student Union", amount: 6.45, date: .now.addingTimeInterval(-46800), category: .personal),
        .init(id: UUID(), title: "Groceries - Campus Mart", amount: 42.18, date: .now.addingTimeInterval(-86400), category: .groceries),
        .init(id: UUID(), title: "Dining Hall Reload", amount: 22.00, date: .now.addingTimeInterval(-129600), category: .mealPlan),
        .init(id: UUID(), title: "Spotify Student", amount: 5.99, date: .now.addingTimeInterval(-172800), category: .subscriptions),
        .init(id: UUID(), title: "Uber to Internship Fair", amount: 14.25, date: .now.addingTimeInterval(-216000), category: .transportation),
        .init(id: UUID(), title: "Gas - Shell", amount: 28.50, date: .now.addingTimeInterval(-259200), category: .transportation),
        .init(id: UUID(), title: "Laundry Room", amount: 8.00, date: .now.addingTimeInterval(-302400), category: .utilities),
        .init(id: UUID(), title: "Late Night Takeout", amount: 17.80, date: .now.addingTimeInterval(-388800), category: .mealPlan),
        .init(id: UUID(), title: "Utilities - Power", amount: 54.20, date: .now.addingTimeInterval(-432000), category: .utilities),
        .init(id: UUID(), title: "Notebook + Supplies", amount: 19.60, date: .now.addingTimeInterval(-518400), category: .personal)
    ]
}
