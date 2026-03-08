import Foundation

struct FallbackEngine: Sendable {
    nonisolated init() {}

    nonisolated func snapshotInsight(for input: BudgetInput) -> AIResponse {
        let rent = input.getExpense(named: "Rent")
        let mealPlan = input.getExpense(named: "Meal Plan")
        let groceries = input.getExpense(named: "Groceries")
        let transportation = input.getExpense(named: "Transport")
        let subscriptions = input.getExpense(named: "Subscriptions")
        let personal = input.getExpense(named: "Personal")
        let tuition = input.getExpense(named: "Tuition")
        let aidScholarships = input.getExpense(named: "Scholarships & Aid")
        let monthlyIncome = input.incomes.map { $0.budget }.reduce(0, +)
        
        let essentials = rent + mealPlan + groceries + transportation
        let flexible = subscriptions + personal
        let outflow = totalOutflow(for: input)
        let netAfterAid = max(0, tuition - aidScholarships)
        let aidPct = aidScholarships / max(1, tuition)
        let monthlyGap = monthlyIncome - outflow

        let flexibility: Flexibility
        if monthlyGap < 180 {
            flexibility = .tight
        } else if monthlyGap < 420 {
            flexibility = .moderate
        } else {
            flexibility = .comfortable
        }

        var points: [String] = []
        let largest = [
            ("Housing", rent),
            ("Tuition (net)", netAfterAid),
            ("Meal plan", mealPlan),
            ("Groceries", groceries),
            ("Transportation", transportation)
        ].max(by: { $0.1 < $1.1 })

        if let largest {
            points.append("\(largest.0) is your biggest cost pressure—keep an eye on it.")
        }
        if aidPct >= 0.82 {
            points.append("Aid covers a solid \(Int(aidPct * 100))% of tuition.")
        } else {
            points.append("Aid only covers \(Int(aidPct * 100))% of tuition. The rest is on you—plan for it.")
        }
        if flexible > essentials * 0.38 {
            points.append("Flexible spending is high vs essentials. Easy to overspend there.")
        } else if flexible > essentials * 0.28 {
            points.append("Flexible spending is creeping up. Don’t let it get out of hand.")
        } else {
            points.append("Flexible spending is under control relative to essentials.")
        }
        if mealPlan > 0 {
            points.append("Meal plan helps, but don’t lean on takeout too much.")
        }

        let summary = "Your \(input.budgetStyle.displayName.lowercased()) budget is \(flexibility.rawValue). Main pressure: \(largest?.0.lowercased() ?? "core costs"). Net tuition after aid: \(netAfterAid.formatted(.currency(code: "USD")))."

        return AIResponse(
            status: "fallback",
            summary: summary,
            points: Array(points.prefix(4)),
            flexibility: flexibility,
            impact: nil,
            suggestions: awarenessSuggestions(for: input, flexibility: flexibility)
        )
    }

    nonisolated func affordabilityInsight(for input: PurchaseInput) -> AIResponse {
        let personal = input.snapshot.getExpense(named: "Personal")
        let subscriptions = input.snapshot.getExpense(named: "Subscriptions")
        let discretionary = max(1, personal + subscriptions)
        let impactRatio = input.amount / discretionary

        let impact: Impact
        if impactRatio < 0.10 {
            impact = .lowImpact
        } else if impactRatio < 0.32 {
            impact = .moderateImpact
        } else {
            impact = .highImpact
        }

        let runwayChange = input.amount / 4
        let summary: String
        switch impact {
        case .lowImpact:
            summary = "\(input.name) is a small hit—about \(runwayChange.formatted(.currency(code: "USD")))/week. Still, little stuff adds up."
        case .moderateImpact:
            summary = "\(input.name) bites into your runway by ~\(runwayChange.formatted(.currency(code: "USD")))/week. Not crazy, but not nothing either."
        case .highImpact:
            summary = "\(input.name) takes a big chunk of discretionary money. Either cut something else or skip it."
        }

        return AIResponse(
            status: "fallback",
            summary: summary,
            points: [
                "Impact: \(impact.displayName).",
                "Discretionary pool: \(discretionary.formatted(.currency(code: "USD")))."
            ],
            flexibility: snapshotInsight(for: input.snapshot).flexibility,
            impact: impact,
            suggestions: [
                "If you buy it, trim another category so the math still works.",
                "One splurge is fine; a habit of them isn’t."
            ]
        )
    }

    nonisolated func scenarioInsight(for input: ScenarioInput) -> AIResponse {
        let totalA = totalOutflow(for: input.scenarioA)
        let totalB = totalOutflow(for: input.scenarioB)
        let delta = totalB - totalA

        let summary: String
        if abs(delta) < 25 {
            summary = "\(input.nameA) and \(input.nameB) are very close in overall pressure, so the main difference is where spending concentration shifts."
        } else if delta > 0 {
            summary = "\(input.nameB) increases expected pressure by \(delta.formatted(.currency(code: "USD"))) versus \(input.nameA), mainly through fixed-cost tradeoffs."
        } else {
            summary = "\(input.nameB) reduces expected pressure by \((-delta).formatted(.currency(code: "USD"))) versus \(input.nameA), giving more flexibility buffer."
        }

        let points = [
            "\(input.nameA): \(totalA.formatted(.currency(code: "USD"))) estimated outflow.",
            "\(input.nameB): \(totalB.formatted(.currency(code: "USD"))) estimated outflow.",
            "Difference: \(delta.formatted(.currency(code: "USD")))."
        ]

        return AIResponse(
            status: "fallback",
            summary: summary,
            points: points,
            flexibility: delta > 200 ? .tight : (delta > 0 ? .moderate : .comfortable),
            impact: nil,
            suggestions: [
                "Compare which version keeps essential costs steadier.",
                "Pick the setup that leaves a more consistent week-to-week cushion."
            ]
        )
    }

    nonisolated func parseTransactionFallback(_ userText: String) -> ParsedTransactionInput? {
        let trimmed = userText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var amount: Double = 0
        var title = trimmed
        var dateDescription = "today"
        let lower = trimmed.lowercased()
        if lower.contains("yesterday") { dateDescription = "yesterday" }

        let amountPattern = #"(?:^\$?\s*|\s+)(\d+(?:[.,]\d+)?)\s*(?:\$|dollars?|for|on|at|$)"#
        if let regex = try? NSRegularExpression(pattern: amountPattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
           let range = Range(match.range(at: 1), in: trimmed) {
            let numStr = String(trimmed[range]).replacingOccurrences(of: ",", with: ".")
            amount = Double(numStr) ?? 0
            title = (trimmed as NSString).replacingCharacters(in: match.range, with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if amount == 0 {
            let simplePattern = #"\$?\s*(\d+(?:[.,]\d+)?)\s*\$?"#
            if let regex = try? NSRegularExpression(pattern: simplePattern),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
               let range = Range(match.range(at: 1), in: trimmed) {
                let numStr = String(trimmed[range]).replacingOccurrences(of: ",", with: ".")
                amount = Double(numStr) ?? 0
                title = (trimmed as NSString).replacingCharacters(in: match.range, with: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        if amount == 0 {
            let digitOnly = #"(\d+(?:[.,]\d+)?)"#
            if let regex = try? NSRegularExpression(pattern: digitOnly),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
               let range = Range(match.range(at: 1), in: trimmed) {
                let numStr = String(trimmed[range]).replacingOccurrences(of: ",", with: ".")
                amount = Double(numStr) ?? 0
                title = (trimmed as NSString).replacingCharacters(in: match.range, with: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        let stopWords = [" for ", " on ", " at ", " dollars", " dollar", " spent", " paid", " cost", " - ", " – "]
        var cleaned = title
        for w in stopWords {
            cleaned = cleaned.replacingOccurrences(of: w, with: " ", options: .caseInsensitive)
        }
        cleaned = cleaned
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if !cleaned.isEmpty {
            title = cleaned
                .components(separatedBy: " ")
                .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
                .joined(separator: " ")
        }
        if title.isEmpty { title = "Expense" }

        let categoryKey = Self.inferCategoryKey(title: title, originalInput: lower)

        return ParsedTransactionInput(
            transactionTitle: title,
            amount: max(0, amount),
            categoryKey: categoryKey,
            dateDescription: dateDescription
        )
    }

    private static nonisolated func inferCategoryKey(title: String, originalInput: String) -> String {
        let t = title.lowercased()
        let o = originalInput
        if t.contains("uber eats") || t.contains("ubereats") || t.contains("doordash") || t.contains("door dash")
            || t.contains("grubhub") || t.contains("delivery") || t.contains("takeout") || t.contains("take out")
            || o.contains("uber eats") || o.contains("doordash") || o.contains("delivery") || o.contains("takeout") {
            return "mealPlan"
        }
        if t.contains("uber") || t.contains("lyft") || t.contains("gas") || t.contains("parking")
            || t.contains("transit") || t.contains("bus") || t.contains("train") {
            return "transportation"
        }
        if t.contains("grocer") || t.contains("trader joe") || t.contains("aldi") || t.contains("walmart")
            || t.contains("costco") || t.contains("food") || t.contains("supermarket") {
            return "groceries"
        }
        if t.contains("coffee") || t.contains("starbucks") || t.contains("dunkin") || t.contains("cafe")
            || t.contains("snack") || t.contains("bubble tea") {
            return "personal"
        }
        if t.contains("netflix") || t.contains("spotify") || t.contains("streaming") || t.contains("subscription")
            || t.contains("hulu") || t.contains("disney") || t.contains("apple music") {
            return "subscriptions"
        }
        if t.contains("rent") || t.contains("housing") || t.contains("lease") { return "rent" }
        if t.contains("electric") || t.contains("water") || t.contains("phone bill") || t.contains("utility")
            || t.contains("wifi") || t.contains("internet") { return "utilities" }
        if t.contains("textbook") || t.contains("tuition") || t.contains("school") { return "tuition" }
        return "personal"
    }

    nonisolated func spendingPressureInsights(for input: BudgetInput) -> [String] {
        var result: [String] = []
        let rent = input.getExpense(named: "Rent")
        let mealPlan = input.getExpense(named: "Meal Plan")
        let groceries = input.getExpense(named: "Groceries")
        let transportation = input.getExpense(named: "Transport")
        let subscriptions = input.getExpense(named: "Subscriptions")
        let personal = input.getExpense(named: "Personal")
        let monthlyIncome = input.incomes.map { $0.budget }.reduce(0, +)


        if rent >= max(mealPlan, groceries, transportation, subscriptions, personal) {
            result.append("Housing is your biggest fixed cost—no room to slip there.")
        }

        if subscriptions >= 18 {
            result.append("Subscriptions add up. Audit them before they bleed you.")
        }

        let essentials = rent + mealPlan + groceries + transportation
        let monthlyBuffer = monthlyIncome - (essentials + personal + subscriptions + input.savingsGoal)
        if monthlyBuffer < 180 {
            result.append("Very little wiggle room after essentials. One big spend hurts.")
        } else if monthlyBuffer < 320 {
            result.append("Buffer is okay but not great. Watch discretionary spending.")
        }

        if mealPlan > 0 {
            result.append("Meal plan helps—rely on it instead of extra food spend.")
        }

        if result.isEmpty {
            result.append("Spending pressure is balanced for now. Don’t get complacent.")
        }

        return result
    }

    private nonisolated func totalOutflow(for input: BudgetInput) -> Double {
        let allExpenses = input.expenses.filter { $0.name != "Scholarships & Aid" }.map { $0.budget }.reduce(0, +)
        let aid = input.getExpense(named: "Scholarships & Aid")
        return allExpenses + input.savingsGoal - aid
    }

    private nonisolated func awarenessSuggestions(for input: BudgetInput, flexibility: Flexibility) -> [String] {
        var suggestions: [String] = []
        let subscriptions = input.getExpense(named: "Subscriptions")
        if flexibility == .tight {
            suggestions.append("Check in weekly. You don’t have room for surprises.")
        }
        if subscriptions > 0 {
            suggestions.append("Cut or pause subscriptions you don’t use.")
        }
        suggestions.append("Groceries and personal spending are where most people blow it—watch those first.")
        return suggestions
    }
}
