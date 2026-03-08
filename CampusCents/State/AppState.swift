//we had assistance from AI for the insights and ideas

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false {
        didSet { save() }
    }
    @Published var profile: StudentProfile = .sample {
        didSet { save() }
    }
    @Published var categories: [BudgetCategory] = BudgetCategory.sample {
        didSet { save() }
    }
    @Published var transactions: [Transaction] = Transaction.sample {
        didSet { save() }
    }

    private let saveKey = "CampusCents.persisted.v1"
    private var restoring = false

    init() {
        restore()
    }

    var total: Double {
        categories.filter { $0.kind != .aid }.map(\.budget).reduce(0, +)
    }

    var spent: Double {
        categories.filter { $0.kind != .aid }.map(\.spent).reduce(0, +)
    }

    var remaining: Double {
        max(0, total - spent)
    }

    var fixedSpend: Double {
        profile.rent + profile.utilities + profile.mealPlan + profile.subscriptions
    }

    var variableBudget: Double {
        profile.groceries + profile.transportation + profile.personal
    }

    var healthScore: Int {
        let usage = spent / max(total, 1)
        let score = Int((1.0 - usage) * 100)
        return min(100, max(0, score))
    }

    var insights: [Insight] {
        var items: [Insight] = []

        for category in categories where category.kind != .aid {
            let ratio = category.spent / max(category.budget, 1)
            if ratio > 1.0 {
                items.append(.init(icon: "exclamationmark.triangle.fill", title: "\(category.name) is over budget", detail: "Spent \(category.spent.currency) on a \(category.budget.currency) budget.", tint: Colors.peach))
            } else if ratio > 0.85 {
                items.append(.init(icon: "gauge.with.needle.fill", title: "\(category.name) is close to limit", detail: "Only \((category.budget - category.spent).currency) remains.", tint: Colors.sun))
            }
        }

        let aidPct = profile.scholarshipsAid / max(profile.tuition, 1)
        if aidPct >= 0.7 {
            items.append(.init(icon: "graduationcap.fill", title: "Strong aid coverage", detail: "Aid covers \(Int(aidPct * 100))% of tuition this term.", tint: Colors.mint))
        } else {
            items.append(.init(icon: "book.closed.fill", title: "Tuition pressure detected", detail: "Aid covers \(Int(aidPct * 100))% of tuition. Plan the shortfall early.", tint: Colors.sky))
        }

        if transactions.count >= 2 {
            let lastTwo = transactions.sorted { $0.date > $1.date }.prefix(2)
            let sum = lastTwo.map(\.amount).reduce(0, +)
            if sum > 80 {
                items.append(.init(icon: "bolt.fill", title: "High recent spending", detail: "Last two purchases total \(sum.currency).", tint: Colors.lavender))
            }
        }

        if items.isEmpty {
            items.append(.init(icon: "checkmark.seal.fill", title: "Budget is in a healthy state", detail: "No warning signs right now. Keep logging transactions.", tint: Colors.mint))
        }
        return items
    }

    func completeOnboarding(with profile: StudentProfile) {
        self.profile = profile
        hasCompletedOnboarding = true
    }

    func updateBudget(for kind: BudgetCategory.Kind, value: Double) {
        guard let index = categories.firstIndex(where: { $0.kind == kind }) else { return }
        categories[index].budget = max(0, value)
    }

    func addTransaction(title: String, amount: Double, date: Date, category: BudgetCategory.Kind) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, amount > 0 else { return }

        let transaction = Transaction(id: UUID(), title: trimmed, amount: amount, date: date, category: category)
        transactions.insert(transaction, at: 0)

        guard category != .aid else { return }
        if let index = categories.firstIndex(where: { $0.kind == category }) {
            categories[index].spent += amount
        }
    }

    func deleteTransaction(_ transaction: Transaction) {
        guard let idx = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        let removed = transactions.remove(at: idx)

        guard removed.category != .aid else { return }
        if let categoryIndex = categories.firstIndex(where: { $0.kind == removed.category }) {
            categories[categoryIndex].spent = max(0, categories[categoryIndex].spent - removed.amount)
        }
    }

    func resetForDemo() {
        hasCompletedOnboarding = false
        profile = .sample
        categories = BudgetCategory.sample
        transactions = Transaction.sample
    }

    private func save() {
        guard !restoring else { return }

        let saved = SavedState(
            hasCompletedOnboarding: hasCompletedOnboarding,
            profile: profile,
            categories: categories,
            transactions: transactions
        )

        if let encoded = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode(SavedState.self, from: data) else { return }

        restoring = true
        hasCompletedOnboarding = decoded.hasCompletedOnboarding
        profile = decoded.profile
        categories = decoded.categories
        transactions = decoded.transactions
        restoring = false
    }
}

extension AppState {
    var budgetInput: BudgetInput {
        BudgetInput(
            tuition: profile.tuition,
            aidScholarships: profile.scholarshipsAid,
            rent: profile.rent + profile.utilities,
            mealPlan: profile.mealPlan,
            groceries: profile.groceries,
            transportation: profile.transportation,
            subscriptions: profile.subscriptions,
            personal: profile.personal,
            savingsGoal: profile.savingsGoal,
            monthlyIncome: profile.monthlyIncome,
            investments: profile.investments,
            budgetStyle: profile.budgetStyle,
            housingType: profile.housingType
        )
    }
}

private struct SavedState: Codable {
    var hasCompletedOnboarding: Bool
    var profile: StudentProfile
    var categories: [BudgetCategory]
    var transactions: [Transaction]
}
