import Foundation

enum Prompts: Sendable {
    nonisolated static let systemBehavior = """
    You are an on-device budgeting insight assistant for a college student finance app.
    Your role is to explain budget structure, spending pressure, affordability tradeoffs, and financial patterns in clear, calm language.
    You provide educational budget insight only.
    You do not provide regulated financial advice, investment advice, lending advice, legal advice, or tax advice.
    You should only reason from the data provided.
    Be concise, accurate, and structured.
    Never claim certainty where there is ambiguity.
    Never shame the user.
    """

    nonisolated static func snapshotPrompt(for input: BudgetInput) -> String {
        let incomesList = input.incomes.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        let expensesList = input.expenses.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        
        return """
        Analyze this student budget and return concise structured insights.

        Student budget data:
        Incomes:
        \(incomesList)
        
        Expenses:
        \(expensesList)
        
        - Savings goal: \(input.savingsGoal.formatted(.currency(code: "USD")))
        - Budget style: \(input.budgetStyle.displayName)
        - Housing type: \(input.housingType.displayName)

        Output constraints:
        - Keep summary under 2 sentences.
        - Provide educational budgeting insights only.
        - No investment, loan, debt, legal, or tax recommendations.
        """
    }

    nonisolated static func affordabilityPrompt(for input: PurchaseInput) -> String {
        let incomesList = input.snapshot.incomes.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        let expensesList = input.snapshot.expenses.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        
        return """
        Reflect on affordability impact for this proposed purchase.

        Purchase:
        - Item: \(input.name)
        - Price: \(input.amount.formatted(.currency(code: "USD")))

        Existing budget:
        Incomes:
        \(incomesList)
        
        Expenses:
        \(expensesList)
        
        - Savings goal: \(input.snapshot.savingsGoal.formatted(.currency(code: "USD")))

        Output constraints:
        - Focus on runway, flexibility, and tradeoff framing.
        - Keep summary under 2 sentences.
        - Use educational language, not definitive recommendations.
        """
    }

    nonisolated static func scenarioPrompt(for input: ScenarioInput) -> String {
        let aIncomes = input.scenarioA.incomes.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        let aExpenses = input.scenarioA.expenses.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        
        let bIncomes = input.scenarioB.incomes.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        let bExpenses = input.scenarioB.expenses.map { "- \($0.name): \($0.budget.formatted(.currency(code: "USD")))" }.joined(separator: "\n        ")
        
        return """
        Compare two student budget scenarios using concise, calm language.

        Scenario A: \(input.nameA)
        Incomes:
        \(aIncomes)
        Expenses:
        \(aExpenses)
        - Savings goal: \(input.scenarioA.savingsGoal.formatted(.currency(code: "USD")))

        Scenario B: \(input.nameB)
        Incomes:
        \(bIncomes)
        Expenses:
        \(bExpenses)
        - Savings goal: \(input.scenarioB.savingsGoal.formatted(.currency(code: "USD")))

        Output constraints:
        - Focus on tradeoffs and pressure points.
        - Keep summary under 2 sentences.
        - Avoid definitive advice language.
        """
    }

    /// Short, focused instruction so the model only does extraction (no budgeting advice).
    nonisolated static let transactionParseInstruction = """
    You only extract one expense from the user's message. Output exactly: transactionTitle (Title Case, no numbers or currency), amount (number), categoryKey (one of the allowed keys), dateDescription ("today", "yesterday", or YYYY-MM-DD). No other text.
    """

    nonisolated static func transactionParsePrompt(userText: String, categoryKeys: [String]) -> String {
        let list = categoryKeys.joined(separator: ", ")
        return """
        User said: "\(userText)"

        Extract one expense. Allowed categoryKey values: \(list).
        Rules: transactionTitle = merchant/expense name in Title Case only (e.g. "10 dollars for uber eats" -> "Uber Eats"). amount = the number. dateDescription = "today" or "yesterday" or YYYY-MM-DD. For Uber Eats/DoorDash/delivery use mealPlan. For Uber/Lyft/gas use transportation. For coffee/snacks use personal. For groceries use groceries.
        """
    }
}
