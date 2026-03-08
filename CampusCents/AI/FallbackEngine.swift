//got help from AI for the fall-back mechanism

import Foundation

struct FallbackEngine: Sendable {
    nonisolated init() {}

    nonisolated func snapshotInsight(for input: BudgetInput) -> AIResponse {
        let essentials = input.rent + input.mealPlan + input.groceries + input.transportation
        let flexible = input.subscriptions + input.personal
        let outflow = essentials + flexible + input.savingsGoal
        let netAfterAid = max(0, input.tuition - input.aidScholarships)
        let aidPct = input.aidScholarships / max(1, input.tuition)
        let monthlyGap = input.monthlyIncome - outflow

        let flexibility: Flexibility
        if monthlyGap < 120 {
            flexibility = .tight
        } else if monthlyGap < 350 {
            flexibility = .moderate
        } else {
            flexibility = .comfortable
        }

        var points: [String] = []
        let largest = [
            ("Housing", input.rent),
            ("Tuition (net)", netAfterAid),
            ("Meal plan", input.mealPlan),
            ("Groceries", input.groceries),
            ("Transportation", input.transportation)
        ].max(by: { $0.1 < $1.1 })
        if let largest {
            points.append("\(largest.0) is your biggest cost pressure right now.")
        }
        if aidPct >= 0.65 {
            points.append("Aid offsets a meaningful share of tuition (about \(Int(aidPct * 100))%).")
        } else {
            points.append("Aid only covers about \(Int(aidPct * 100))% of tuition, so tuition still carries pressure.")
        }
        if flexible > essentials * 0.45 {
            points.append("Flexible spending is relatively high compared with essentials.")
        } else {
            points.append("Flexible spending looks controlled relative to essentials.")
        }
        if input.mealPlan > 0 {
            points.append("Meal plan coverage may reduce grocery swings week to week.")
        }

        let summary = "Your \(input.budgetStyle.displayName.lowercased()) setup looks \(flexibility.rawValue), with most pressure from \(largest?.0.lowercased() ?? "core costs"). Net tuition after aid is \(netAfterAid.formatted(.currency(code: "USD")))."

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
        let discretionary = max(1, input.snapshot.personal + input.snapshot.subscriptions)
        let impactRatio = input.amount / discretionary

        let impact: Impact
        if impactRatio < 0.15 {
            impact = .lowImpact
        } else if impactRatio < 0.4 {
            impact = .moderateImpact
        } else {
            impact = .highImpact
        }

        let runwayChange = input.amount / 4
        let summary: String
        switch impact {
        case .lowImpact:
            summary = "\(input.name) is a low-impact add in your current budget. It slightly reduces short-term flexibility by about \(runwayChange.formatted(.currency(code: "USD")))/week."
        case .moderateImpact:
            summary = "\(input.name) creates a moderate budget impact. It narrows your weekly flexibility by roughly \(runwayChange.formatted(.currency(code: "USD"))) and adds a visible tradeoff."
        case .highImpact:
            summary = "\(input.name) creates a high impact on your discretionary runway. This would noticeably tighten flexibility unless another category is adjusted."
        }

        return AIResponse(
            status: "fallback",
            summary: summary,
            points: [
                "Estimated impact level: \(impact.displayName).",
                "Discretionary pool considered: \(discretionary.formatted(.currency(code: "USD")))."
            ],
            flexibility: snapshotInsight(for: input.snapshot).flexibility,
            impact: impact,
            suggestions: [
                "Track whether this changes your remaining weekly runway.",
                "Check if this affects savings consistency this cycle."
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

    nonisolated func spendingPressureInsights(for input: BudgetInput) -> [String] {
        var result: [String] = []

        if input.rent >= max(input.mealPlan, input.groceries, input.transportation, input.subscriptions, input.personal) {
            result.append("Housing is your biggest fixed cost.")
        }

        if input.subscriptions >= 25 {
            result.append("Subscriptions are small individually but meaningful together.")
        }

        let essentials = input.rent + input.mealPlan + input.groceries + input.transportation
        let monthlyBuffer = input.monthlyIncome - (essentials + input.personal + input.subscriptions + input.savingsGoal)
        if monthlyBuffer < 120 {
            result.append("Your budget has limited flexibility after essentials.")
        }

        if input.mealPlan > 0 {
            result.append("Meal plan usage may be helping reduce grocery variability.")
        }

        if result.isEmpty {
            result.append("Spending pressure currently looks balanced across categories.")
        }

        return result
    }

    private nonisolated func totalOutflow(for input: BudgetInput) -> Double {
        input.tuition + input.rent + input.mealPlan + input.groceries + input.transportation + input.subscriptions + input.personal + input.savingsGoal - input.aidScholarships
    }

    private nonisolated func awarenessSuggestions(for input: BudgetInput, flexibility: Flexibility) -> [String] {
        var suggestions: [String] = []
        if flexibility == .tight {
            suggestions.append("Use small weekly check-ins to prevent surprise end-of-cycle pressure.")
        }
        if input.subscriptions > 0 {
            suggestions.append("Review recurring subscriptions each cycle for drift.")
        }
        suggestions.append("Track changes in groceries and personal spending first when flexibility tightens.")
        return suggestions
    }
}
