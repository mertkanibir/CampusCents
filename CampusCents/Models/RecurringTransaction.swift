import Foundation

struct RecurringTransaction: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var category: BudgetCategory.Kind
    var frequency: Frequency
    var startDate: Date
    var nextDueDate: Date

    enum Frequency: String, Codable, CaseIterable {
        case weekly
        case monthly

        var displayName: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            }
        }
    }

    init(id: UUID = UUID(), title: String, amount: Double, category: BudgetCategory.Kind, frequency: Frequency, startDate: Date, nextDueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.frequency = frequency
        self.startDate = startDate
        self.nextDueDate = nextDueDate ?? startDate
    }

    mutating func advanceNextDue() {
        let cal = Calendar.current
        switch frequency {
        case .weekly:
            nextDueDate = cal.date(byAdding: .weekOfYear, value: 1, to: nextDueDate) ?? nextDueDate
        case .monthly:
            nextDueDate = cal.date(byAdding: .month, value: 1, to: nextDueDate) ?? nextDueDate
        }
    }
}
