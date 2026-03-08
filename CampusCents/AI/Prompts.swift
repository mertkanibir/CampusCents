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
        """
        Analyze this student budget and return concise structured insights.

        Student budget data:
        - Tuition: \(input.tuition.formatted(.currency(code: "USD")))
        - Aid/Scholarships: \(input.aidScholarships.formatted(.currency(code: "USD")))
        - Housing: \(input.rent.formatted(.currency(code: "USD")))
        - Meal plan: \(input.mealPlan.formatted(.currency(code: "USD")))
        - Groceries: \(input.groceries.formatted(.currency(code: "USD")))
        - Transportation: \(input.transportation.formatted(.currency(code: "USD")))
        - Subscriptions: \(input.subscriptions.formatted(.currency(code: "USD")))
        - Personal spending: \(input.personal.formatted(.currency(code: "USD")))
        - Savings goal: \(input.savingsGoal.formatted(.currency(code: "USD")))
        - Monthly income: \(input.monthlyIncome.formatted(.currency(code: "USD")))
        - Budget style: \(input.budgetStyle.displayName)
        - Housing type: \(input.housingType.displayName)

        Output constraints:
        - Keep summary under 2 sentences.
        - Provide educational budgeting insights only.
        - No investment, loan, debt, legal, or tax recommendations.
        """
    }

    nonisolated static func affordabilityPrompt(for input: PurchaseInput) -> String {
        """
        Reflect on affordability impact for this proposed purchase.

        Purchase:
        - Item: \(input.name)
        - Price: \(input.amount.formatted(.currency(code: "USD")))

        Existing budget:
        - Tuition: \(input.snapshot.tuition.formatted(.currency(code: "USD")))
        - Aid: \(input.snapshot.aidScholarships.formatted(.currency(code: "USD")))
        - Housing: \(input.snapshot.rent.formatted(.currency(code: "USD")))
        - Meal plan: \(input.snapshot.mealPlan.formatted(.currency(code: "USD")))
        - Groceries: \(input.snapshot.groceries.formatted(.currency(code: "USD")))
        - Transportation: \(input.snapshot.transportation.formatted(.currency(code: "USD")))
        - Subscriptions: \(input.snapshot.subscriptions.formatted(.currency(code: "USD")))
        - Personal spending: \(input.snapshot.personal.formatted(.currency(code: "USD")))
        - Savings goal: \(input.snapshot.savingsGoal.formatted(.currency(code: "USD")))
        - Monthly income: \(input.snapshot.monthlyIncome.formatted(.currency(code: "USD")))

        Output constraints:
        - Focus on runway, flexibility, and tradeoff framing.
        - Keep summary under 2 sentences.
        - Use educational language, not definitive recommendations.
        """
    }

    nonisolated static func scenarioPrompt(for input: ScenarioInput) -> String {
        """
        Compare two student budget scenarios using concise, calm language.

        Scenario A: \(input.nameA)
        - Tuition: \(input.scenarioA.tuition.formatted(.currency(code: "USD")))
        - Aid: \(input.scenarioA.aidScholarships.formatted(.currency(code: "USD")))
        - Housing: \(input.scenarioA.rent.formatted(.currency(code: "USD")))
        - Meal plan: \(input.scenarioA.mealPlan.formatted(.currency(code: "USD")))
        - Groceries: \(input.scenarioA.groceries.formatted(.currency(code: "USD")))
        - Transportation: \(input.scenarioA.transportation.formatted(.currency(code: "USD")))
        - Subscriptions: \(input.scenarioA.subscriptions.formatted(.currency(code: "USD")))
        - Personal spending: \(input.scenarioA.personal.formatted(.currency(code: "USD")))
        - Savings goal: \(input.scenarioA.savingsGoal.formatted(.currency(code: "USD")))

        Scenario B: \(input.nameB)
        - Tuition: \(input.scenarioB.tuition.formatted(.currency(code: "USD")))
        - Aid: \(input.scenarioB.aidScholarships.formatted(.currency(code: "USD")))
        - Housing: \(input.scenarioB.rent.formatted(.currency(code: "USD")))
        - Meal plan: \(input.scenarioB.mealPlan.formatted(.currency(code: "USD")))
        - Groceries: \(input.scenarioB.groceries.formatted(.currency(code: "USD")))
        - Transportation: \(input.scenarioB.transportation.formatted(.currency(code: "USD")))
        - Subscriptions: \(input.scenarioB.subscriptions.formatted(.currency(code: "USD")))
        - Personal spending: \(input.scenarioB.personal.formatted(.currency(code: "USD")))
        - Savings goal: \(input.scenarioB.savingsGoal.formatted(.currency(code: "USD")))

        Output constraints:
        - Focus on tradeoffs and pressure points.
        - Keep summary under 2 sentences.
        - Avoid definitive advice language.
        """
    }
}
