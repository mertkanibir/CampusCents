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
    @Published var templates: [TransactionTemplate] = TransactionTemplate.defaults {
        didSet { saveTemplatesAndRecurring() }
    }
    @Published var recurring: [RecurringTransaction] = [] {
        didSet { saveTemplatesAndRecurring() }
    }

    private let saveKey = "CampusCents.persisted.v1"
    private let templatesRecurringKey = "CampusCents.templatesRecurring.v1"
    private var restoring = false

    init() {
        restore()
    }

    var total: Double {
        categories.filter { !$0.kind.isIncome && $0.kind != .aid }.map(\.budget).reduce(0, +)
    }

    var spent: Double {
        categories.filter { !$0.kind.isIncome && $0.kind != .aid }.map(\.spent).reduce(0, +)
    }

    var remaining: Double {
        let totalIncome = categories.filter { $0.kind.isIncome }.map(\.budget).reduce(0, +)
        return max(0, totalIncome - total)
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
                items.append(.init(id: "over-\(category.id.uuidString)", icon: "exclamationmark.triangle.fill", title: "\(category.name) is over budget", detail: "Spent \(category.spent.currency) on a \(category.budget.currency) budget.", tint: Colors.peach, tone: .watch))
            } else if ratio > 0.85 {
                items.append(.init(id: "limit-\(category.id.uuidString)", icon: "gauge.with.needle.fill", title: "\(category.name) is close to limit", detail: "Only \((category.budget - category.spent).currency) remains.", tint: Colors.sun, tone: .watch))
            }
        }

        let aidPct = profile.scholarshipsAid / max(profile.tuition, 1)
        if aidPct >= 0.7 {
            items.append(.init(id: "aid-strong", icon: "graduationcap.fill", title: "Strong aid coverage", detail: "Aid covers \(Int(aidPct * 100))% of tuition this term.", tint: Colors.mint, tone: .positive))
        } else {
            items.append(.init(id: "aid-pressure", icon: "book.closed.fill", title: "Tuition pressure detected", detail: "Aid covers \(Int(aidPct * 100))% of tuition. Plan the shortfall early.", tint: Colors.sky, tone: .watch))
        }

        if transactions.count >= 2 {
            let lastTwo = transactions.sorted { $0.date > $1.date }.prefix(2)
            let sum = lastTwo.map(\.amount).reduce(0, +)
            if sum > 80 {
                items.append(.init(id: "recent-spending", icon: "bolt.fill", title: "High recent spending", detail: "Last two purchases total \(sum.currency).", tint: Colors.lavender, tone: .watch))
            }
        }

        if items.isEmpty {
            items.append(.init(id: "healthy-state", icon: "checkmark.seal.fill", title: "Budget is in a healthy state", detail: "No warning signs right now. Keep logging transactions.", tint: Colors.mint, tone: .positive))
        }
        return items
    }

    func completeOnboarding(with profile: StudentProfile) {
        self.profile = profile
        categories = BudgetCategory.from(profile: profile)
        hasCompletedOnboarding = true
    }

    func updateBudget(for kind: BudgetCategory.Kind, value: Double) {
        guard let index = categories.firstIndex(where: { $0.kind == kind }) else { return }
        categories[index].budget = max(0, value)
        
        if kind == .income {
            profile.monthlyIncome = max(0, value)
            categories[index].spent = max(0, value)
        } else if kind == .investment {
            profile.investments = max(0, value)
        } else if case .custom(let id, _, _, _, _, _) = kind {
            if let customIdx = profile.customCategories.firstIndex(where: {
                if case .custom(let cid, _, _, _, _, _) = $0.kind { return cid == id }
                return false
            }) {
                profile.customCategories[customIdx].budget = max(0, value)
            }
        }
    }

    func addCustomCategory(name: String, desc: String, budget: Double, isIncome: Bool, icon: String, color: Color) {
        let idString = UUID().uuidString
        let newKind = BudgetCategory.Kind.custom(id: idString, name: name, desc: desc, icon: icon, tint: ColorValue(color), isIncome: isIncome)
        let newCategory = BudgetCategory(id: UUID(), kind: newKind, name: name, budget: budget, spent: 0, color: ColorValue(color))
        
        categories.append(newCategory)
        profile.customCategories.append(newCategory)
    }

    func removeCategory(_ category: BudgetCategory) {
        categories.removeAll { $0.id == category.id }
        profile.customCategories.removeAll { $0.id == category.id }
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

    func addTemplate(_ template: TransactionTemplate) {
        templates.append(template)
    }

    func removeTemplate(_ template: TransactionTemplate) {
        templates.removeAll { $0.id == template.id }
    }

    func addRecurring(_ recurring: RecurringTransaction) {
        self.recurring.append(recurring)
    }

    func removeRecurring(_ recurring: RecurringTransaction) {
        self.recurring.removeAll { $0.id == recurring.id }
    }

    func addOccurrence(for recurring: RecurringTransaction) {
        let date = max(recurring.nextDueDate, Calendar.current.startOfDay(for: Date()))
        addTransaction(title: recurring.title, amount: recurring.amount, date: date, category: recurring.category)
        if let idx = self.recurring.firstIndex(where: { $0.id == recurring.id }) {
            self.recurring[idx].advanceNextDue()
        }
    }

    func resetForDemo() {
        hasCompletedOnboarding = false
        profile = .sample
        categories = BudgetCategory.sample
        transactions = Transaction.sample
        templates = TransactionTemplate.defaults
        recurring = []
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
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(SavedState.self, from: data) {
            restoring = true
            hasCompletedOnboarding = decoded.hasCompletedOnboarding
            profile = decoded.profile
            categories = decoded.categories
            
            if !categories.contains(where: { $0.kind == .income }) {
                categories.insert(.init(id: UUID(), kind: .income, name: "Monthly Income", budget: profile.monthlyIncome, spent: profile.monthlyIncome, color: .init(Colors.mint)), at: 0)
            }
            if !categories.contains(where: { $0.kind == .investment }) {
                categories.insert(.init(id: UUID(), kind: .investment, name: "Investments", budget: profile.investments, spent: 0, color: .init(Colors.periwinkle)), at: 1)
            }
            
            transactions = decoded.transactions
            restoring = false
        }
        if let data = UserDefaults.standard.data(forKey: templatesRecurringKey),
           let decoded = try? JSONDecoder().decode(TemplatesRecurringState.self, from: data) {
            templates = decoded.templates
            recurring = decoded.recurring
        }
    }

    private func saveTemplatesAndRecurring() {
        guard !restoring else { return }
        let state = TemplatesRecurringState(templates: templates, recurring: recurring)
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: templatesRecurringKey)
        }
    }
}

extension AppState {
    var budgetInput: BudgetInput {
        let incomes = categories.filter { $0.kind.isIncome }.map {
            BudgetInput.CategoryInput(name: $0.name, budget: $0.budget, spent: $0.spent)
        }
        let expenses = categories.filter { !$0.kind.isIncome }.map {
            BudgetInput.CategoryInput(name: $0.name, budget: $0.budget, spent: $0.spent)
        }
        
        return BudgetInput(
            savingsGoal: profile.savingsGoal,
            budgetStyle: profile.budgetStyle,
            housingType: profile.housingType,
            incomes: incomes,
            expenses: expenses
        )
    }
}

private struct SavedState: Codable {
    var hasCompletedOnboarding: Bool
    var profile: StudentProfile
    var categories: [BudgetCategory]
    var transactions: [Transaction]
}

private struct TemplatesRecurringState: Codable {
    var templates: [TransactionTemplate]
    var recurring: [RecurringTransaction]
}
